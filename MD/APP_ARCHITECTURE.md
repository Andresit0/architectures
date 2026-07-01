### Architecture (clean + feature-first)

```
lib/features/<feature>/
  domain/          ← interfaces (i_*.dart), entities, usecases — no Flutter imports
  infrastructure/  ← datasource impl, mapper, repository impl
  presentation/    ← Riverpod notifiers/providers (.g.dart), screens, widgets

lib/shared/
  configs/         ← CustomConfigs barrel (_configs.lib.dart + _configs.dart). App variables like Colors, Strings., etc
  database/        ← AppDatabase (Drift); barrel _database.lib.dart
  functions/       ← CustomFunction barrel (_function.lib.dart + _function.dart)
                      cp_<package>.dart wrappers + service classes
  exceptions/      ← Failure classes, Exception classes, Either re-export
                      (_exceptions.lib.dart + _exceptions.dart barrel)
  interceptors/    ← CustomInterceptors barrel (_interceptors.lib.dart + _interceptors.dart)
  providers/       ← Riverpod shared providers (dio, token, sharePlus, user, goRouter)
  jsons/           ← CustomJsons barrel (_jsons.lib.dart + _jsons.dart); mock/test JSON data
                      Access via CustomJsons.userJson
```

---

### Either / Failure data flow

All fallible operations return `Either<Failure, T>` (fpdart, via `cp_fpdart.dart`).

```
cp_dio → throws typed Exception
datasource → raw call, no try/catch
repository → CustomFunction.fpdart.guard(() => datasource.call())  ← creates Either
usecase    → passes Either through unchanged
notifier   → result.fold(onLeft, onRight)                          ← consumes Either
```

> See **MD/APP_DARTZ.md** for the full pattern, code examples and checklist.