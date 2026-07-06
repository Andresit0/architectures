### Architecture (clean + feature-first)

```
lib/features/<feature>/
  domain/          ← interfaces (i_*.dart), entities, usecases — no Flutter imports
  infrastructure/  ← datasource impl, mapper, repository impl
  presentation/    ← Riverpod notifiers/providers (.g.dart), screens, widgets

lib/shared/
  configs/         ← CustomConfigs barrel (_configs.lib.dart + _configs.dart). App variables like Colors, Strings., etc
  models/          ← CustomModels barrel (_models.lib.dart + _models.dart). Domain entities shared across features: patient/, clinical_history/
  database/        ← AppDatabase (sembast, AES-256-CBC via codec); barrel _database.lib.dart + _database.dart exposing CustomDb.clinicalHistory
  functions/       ← CustomFunction barrel (_function.lib.dart + _function.dart)
                      cp_<package>.dart wrappers + service classes
  exceptions/      ← Failure classes, Exception classes, Either re-export
                      (_exceptions.lib.dart + _exceptions.dart barrel)
  interceptors/    ← CustomInterceptors barrel (_interceptors.lib.dart + _interceptors.dart)
  providers/       ← Riverpod shared providers (dio, token, goRouter, sembast)
  jsons/           ← CustomJsons barrel (_jsons.lib.dart + _jsons.dart); mock/test JSON data
                       Access via CustomJsons.authJson
```

---

### Either / Failure data flow

All fallible operations return `Either<Failure, T>` (fpdart, via `cp_fpdart.dart`).

```
cp_dio → throws typed Exception
datasource → raw call, no try/catch
repository → CustomFunction.fpdart.guard(() => datasource.call())  ← creates Either
             or fetchOrFallback(remote: guard, local: guard)       ← offline-first fallback
usecase    → passes Either through unchanged
notifier   → result.fold(onLeft, onRight)                          ← consumes Either
```

> See **MD/APP_DARTZ.md** for the full pattern, code examples and checklist.

### Offline-first fallback pattern

When a method should fall back to cached data on connection failure:

```
repository → fetchOrFallback(remote: guard(() => remoteDs.method()),
                             local:  guard(() => localDs.method()))
  ├── remote OK             → Right(data)
  ├── NoConnection + local  → Right(localData)
  └── NoConnection + null   → Left(connectionFailure)
      or other failure
```

Available as a top-level function from `_function.lib.dart`. Defined in `lib/shared/functions/offline_first_repository.dart`.
AuthInterceptor uses a `checkConnectivity` callback to skip token refresh when offline, preventing user expulsion.