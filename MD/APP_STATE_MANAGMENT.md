### State management

Riverpod v3 (code-gen). Always use `@riverpod` annotation; always re-run `build_runner` after changes.

#### Global shared providers

Four `keepAlive` providers live in `lib/shared/providers/` and are exposed via the `CustomProviders` facade:

```dart
CustomProviders.dio       // Provider<ICpDio>                 — Dio singleton
CustomProviders.token     // Provider<ITokenService>          — token storage singleton
CustomProviders.goRouter  // Provider<GoRouterListenable>      — ChangeNotifier for router refresh
CustomProviders.sembast   // Provider<ICpSembast>             — Sembast database singleton (AES-256-CBC encrypted)
```

- Feature code **always** accesses providers via `CustomProviders.xxx`.
- Files inside `shared/providers/` import each other directly (avoids circular barrel imports).

#### ref.watch / ref.read / ref.listen — quick rule

| Method | Use when |
|---|---|
| `ref.watch` | Inside a functional provider body or widget/Notifier `build()` that needs to rebuild on change |
| `ref.read` | Inside callbacks, `initState`, or Notifier methods (one-shot actions, no reactivity needed) |
| `ref.listen` | Inside a Notifier `build()` to react to another provider without rebuilding the notifier |

> See **MD/APP_PROVIDERS.md** for the full inventory, canonical examples and access rules.