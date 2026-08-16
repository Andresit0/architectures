# Local Database Upgrade Policy (D3)

## Context

`from_first_day_1` creates the local Sembast database without an encrypted
codec. The migration (PR 7) switches `AppDatabase` to an AES-256-CBC codec
(`lib/core/database/sembast_codec.dart`) applied to the on-disk file and the
in-memory test factory, and splits session/clinical-history storage. The
`catch`-that-deletes-the-database must NOT be the only migration strategy.

## Chosen policy: invalidación y rehidratación (cache derived from server)

The local database is a **derived cache** of server data (session token,
patient info and clinical history), not a clinical source of truth. On the
first launch after upgrade the app must:

1. **Detect incompatibility** — if the stored format cannot be opened with the
   current codec/schema (`SembastCodec` mismatch or unreadable file), treat the
   local store as incompatible.
2. **Delete only the incompatible cache** — `resetDatabase()` removes the DB
   file AND the encryption key. This is scoped to cache, never the user session
   when the session can be restored safely.
3. **Rehydrate online** — `RestoreSessionUseCase` re-fetches from the server;
   clinical history refills via the online-first load (remote → write-through
   to cache).
4. **Keep the session when safe** — session restore uses server-backed
   credentials/token refresh; a codec wipe does not force logout.

## When NOT to use this policy

- If the cache ever carries data with clinical/regulatory value that cannot be
  re-fetched, switch to **migración preservando datos**: version the
  schema/codec, prove upgrade from a fixture DB, and provide rollback.
- If integrity cannot be guaranteed, choose **bloqueo de upgrade** and stop the
  deployment instead of silently wiping.

## Rollback

- Code rollback: `hotfix/*` from `main` or revert the squash commit.
- Data rollback: reinstalling the previous binary over data created by the new
  format requires a **downgrade test over a fixture DB** before release; the
  codec change is not backward-readable by the old binary.

## Tests required (landing in PR 7)

- `test/core/database/sembast_codec_test.dart` — AES codec round-trip.
- `test/core/database/app_database_encrypted_test.dart` — in-memory factory
  uses the codec.
- `test/core/database/app_database_reset_test.dart` — reset removes file + key.
- Fixture-based upgrade test simulating a legacy (unencrypted) DB being opened
  by the new build.
