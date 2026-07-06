### Shared providers — usage rules

All global providers live in `lib/shared/providers/`.
The `CustomProviders` facade (in `_providers.dart`) exposes them under static aliases.

---

#### Inventory of the 4 global providers

| `CustomProviders` alias | Raw provider | Type | Exposed state |
|---|---|---|---|---|
| `CustomProviders.dio` | `httpServiceProvider` | `Provider<ICpDio>` | HTTP singleton (Dio) |
| `CustomProviders.token` | `tokenServiceProvider` | `Provider<ITokenService>` | Token storage singleton |
| `CustomProviders.goRouter` | `goRouterListenableProvider` | `Provider<GoRouterListenable>` | `ChangeNotifier` that notifies the router when `isAuthenticated` changes |
| `CustomProviders.sembast` | `sembastProvider` | `Provider<ICpSembast>` | Sembast database singleton (AES-256-CBC encrypted) |

All are `keepAlive: true` — never discarded from memory.

---

#### Access rule: `CustomProviders` vs direct import

| From | Use | Reason |
|---|---|---|
| Code in `features/` | `CustomProviders.xxx` | The barrel centralizes access; never import the provider file directly |
| Code inside `shared/providers/` | Direct import of the file (`token_provider.dart`, etc.) | Provider files use `@riverpod` and declare their own `part '...g.dart'`; importing them from the barrel (`_providers.lib.dart`) would cause circular dependencies if the barrel re-imports them

---

#### Method rule: `ref.watch` / `ref.read` / `ref.listen`

| Method | Correct context | Typical error |
|---|---|---|
| `ref.watch` | Functional provider body (`@riverpod` function). `build()` of widget/Notifier when UI must rebuild when value changes | Using it inside callbacks or async Notifier methods → runtime error |
| `ref.read` | Callbacks, `initState`, Notifier methods (one-shot actions without reactivity) | Using it in `build()` of a widget for reactive data → the widget won't rebuild |
| `ref.listen` | `build()` of a Notifier to react to changes without rebuilding. `build()` of a widget for side-effects | Confusing it with `ref.watch`: `listen` only fires the callback, doesn't rebuild |

---

#### Canonical examples by context

**Functional provider — builds a datasource**
```dart
// CORRECT: ref.watch to declare dependencies
@riverpod
IAuthDatasource userDatasource(Ref ref) =>
    AuthDatasourceImpl(ref.watch(CustomProviders.dio));

@riverpod
IEncounterDatasource encounterDatasource(Ref ref) =>
    EncounterDatasourceImpl(
      ref.watch(CustomProviders.token),
      ref.watch(CustomProviders.dio),
    );
```

**Notifier — async method (callback)**
```dart
// CORRECT: ref.read for one-shot actions
Future<void> doLogin(LoginResponseEntity entity) async {
  await ref.read(CustomProviders.token).save(user.token);
}

// CORRECT: ref.read in logout
Future<void> logout() async {
  await ref.read(tokenServiceProvider).delete(); // inside shared/providers/
}
```

**Root widget initState**
```dart
// CORRECT: ref.read to get the listenable and pass it to the router
final notifier = ref.read(CustomProviders.goRouter);
routerConfig: CpGoRouter.create(
  routes: CustomConfigs.routes.goRouter,
  refreshListenable: notifier,
),
```

---

#### GoRouterListenable — ChangeNotifier + Provider pattern

`GoRouterListenable` is a `ChangeNotifier` (not a Riverpod Notifier) that mirrors the authentication state from `auth_notifier.dart` and is passed to `CpGoRouter.create()` as `refreshListenable`. It is a static `Provider<GoRouterListenable>` (not code-gen `@riverpod`). Never access this provider for UI data; its only consumer is `main.dart` which passes it to `CpGoRouter.create()`.
