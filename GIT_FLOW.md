# Plan empresarial para migrar `from_first_day_1` a `from_first_day_2`

## 1. Alcance y criterio rector

Este documento define el plan para llevar el código funcional de
`from_first_day_1` al estado funcional de `from_first_day_2`, sin trasladar
una rama completa de forma ciega y sin perder trazabilidad.

El plan asume una organización grande con estas propiedades:

- `main` es producción y `develop` es integración.
- `main` y `develop` están protegidas y no aceptan pushes directos.
- Todo cambio entra por Pull Request revisable y con CI verde.
- Los commits siguen Conventional Commits y son atómicos.
- El desarrollo usa Specification-Driven Development, TDD, BDD, pruebas de
  integración y pruebas golden.
- Los commits se preparan siguiendo
  `from_first_day_2/.ai/commands/super-commit.md`.
- Los Pull Requests se descomponen y publican siguiendo
  `from_first_day_2/.ai/commands/super-pull-request.md`.
- La revisión y la publicación requieren aprobación explícita; este plan no
  autoriza commits, pushes, merges ni tags por sí mismo.

`GIT_FLOW.md` está actualmente en el directorio de trabajo padre de ambos
repositorios. Para que sea una política empresarial auditable, PR 8 debe copiar
esta versión al root del repositorio canónico y versionarla mediante el PR de
documentación final. El archivo del directorio padre puede conservarse como
working draft, pero no es la fuente oficial después de PR 8.

### 1.1 Veredicto de la revisión 10/10

La versión anterior de este plan **no era 10/10** por cuatro razones:

1. Proponía 15 PRs funcionales separados por carpetas sin demostrar que cada
   estado intermedio compilara.
2. Creaba un stack de 15 niveles, aunque el CI real no se ejecuta para PRs cuyo
   base sea una rama intermedia del stack.
3. Mezclaba en un mismo PR final arquitectura, CI, AI, documentación y
   Dependabot, violando el principio de una decisión por PR.
4. Permitía interpretar RED como parte de la historia publicada, en conflicto
   con la exigencia de que cada commit que llegue a revisión sea compilable y
   verificable.

La corrección se basa en una verificación empírica previa sobre un sandbox del
refactor real: el cambio completo involucra aproximadamente 12 mil líneas y
más de 380 archivos; retirar únicamente partes de `shared/core` produjo 123
errores de análisis, retirar clinical history produjo 122, retirar auth
produjo 81 y aplicar solo features sin sus contratos compartidos produjo 375.
La conclusión es concreta:

- Los cambios aditivos independientes sí deben ser PRs pequeños.
- El núcleo no retrocompatible de auth + clinical history + core + app + tests
  debe viajar como **un único PR funcional atómico**.
- Si la organización no acepta ese PR grande, primero debe financiar una
  migración por compatibilidad, con adapters y deprecaciones; no se debe
  inventar una división que deje ramas no compilables.
- La división final debe tener como máximo dos niveles temporales de stack y
  todos los PRs públicos deben recibir CI contra `develop` antes del merge.

Estado actual del veredicto: el diseño corregido es apto para 10/10, pero el
repositorio todavía no puede declararse 10/10 hasta aplicar D1-D11, fusionar PR
1 y corregir los comandos AI/reviewer. La calidad del plan no sustituye la
evidencia de los controles realmente activos.

## 2. Resultado de la comparación

### 2.1 Estado de los snapshots

| Elemento | `from_first_day_1` | `from_first_day_2` | Consecuencia |
|---|---|---|---|
| Rama observada | `develop` | `feature/clinical-history-extract` | No se debe usar la rama de la feature como base de producción. |
| HEAD observado | `32eb973`, con actualizaciones posteriores de dependencias | `0eca6c0`, anterior al HEAD de `from_first_day_1` | El objetivo parte de un baseline atrasado. |
| Worktree | Solo `pubspec.lock` aparece modificado | Refactorización grande con modificaciones, borrados, renombres y archivos nuevos | No se puede interpretar el estado objetivo como un commit único listo para merge. |
| Estado Git | Tiene una línea de desarrollo integrada | Tiene cambios parcialmente preparados en una rama de feature | Se debe reconstruir la migración sobre el `develop` más reciente. |
| Validación observada | Baseline de desarrollo | `flutter analyze` sin issues; 655 pruebas no-golden, 9 goldens y 6 escenarios de integración pasan localmente en macOS | El comportamiento objetivo es una buena referencia, pero aún necesita integración CI y trazabilidad empresarial. |

La diferencia de HEAD es crítica: `from_first_day_2` no es simplemente una
versión posterior de `from_first_day_1`. Es una implementación extensa hecha
encima de un commit anterior. La operación correcta es:

1. Tomar el `develop` actualizado de `from_first_day_1` como base.
2. Tratar `from_first_day_2` como evidencia de diseño y como fuente de cambios.
3. Reaplicar los cambios por capacidades, respetando dependencias y pruebas.
4. No copiar `.git`, no hacer un merge masivo y no sobrescribir el `pubspec` más
   nuevo sin una decisión técnica explícita.

### 2.2 Diferencias de Git y control del trabajo

`from_first_day_1` representa el flujo integrado de la empresa: `develop` ya
contiene actualizaciones de dependencias, documentación de protección de
ramas y el gate de secretos. `from_first_day_2` contiene una feature grande
con más de un centenar de rutas tocadas, incluyendo archivos borrados y
renombrados.

El cambio de estado no debe resolverse con una sola operación de staging. El
comando `super-commit.md` exige mostrar primero:

- `git status --short`.
- `git diff --stat`.
- `git diff`.
- `git log --oneline -10`.
- Una tabla de archivos y cambios.
- Un escaneo de secretos antes de proponer commits.

La migración solo puede comenzar formalmente después de identificar qué
cambios en `pubspec.lock` de ambos worktrees pertenecen al usuario y cuáles
son generados por la resolución de dependencias. No se deben descartar esos
cambios ni ejecutar comandos destructivos para "limpiar" el estado.

### 2.3 Dependencias, generación y plataforma

Hay una regresión que no debe copiarse del objetivo literal:

| Archivo | Baseline `from_first_day_1` | Objetivo `from_first_day_2` | Decisión de migración |
|---|---|---|---|
| `pubspec.yaml` | `go_router: ^17.5.0` | `go_router: ^17.2.2` | Conservar `^17.5.0`, salvo decisión aprobada y pruebas de compatibilidad. |
| `pubspec.yaml` | Incluye `riverpod_lint: ^3.1.4` | No lo incluye | No eliminarlo; revisar por qué el objetivo quedó atrasado. |
| `.github/dependabot.yml` | Agrupa también `riverpod_lint` | No lo agrupa | Mantener la política del baseline y corregirla si la migración toca el archivo. |
| `pubspec.lock` | Modificado en el worktree | Modificado en el worktree | Regenerar desde el `pubspec.yaml` canónico; nunca editarlo manualmente para simular el objetivo. |
| `dart_test.yaml` | No existe en la comparación | Declara el tag `golden` | Incorporarlo antes de publicar pruebas golden. |
| `*.g.dart`, `*.freezed.dart` | Código generado existente | Muchos archivos regenerados o movidos | Committear solo junto con su fuente y regenerarlos con `build_runner`. |
| Registradores de plugins | Generados por Flutter | Aparecen por builds locales | No incluir `generated_plugin_registrant.*`, `GeneratedPluginRegistrant.*` ni `generated_plugins.cmake`. |

La plataforma agrega deep links para el esquema `clinicalhistory` en
`android/app/src/main/AndroidManifest.xml` e `ios/Runner/Info.plist`. Esos
cambios deben validarse junto con la ruta, no mezclarse con una actualización
de dependencias.

Antes de cada validación de una rama se deben eliminar artefactos locales con
`flutter clean`. La ejecución de integración local mostró warnings de archivos
stale fuera del root actual, por lo que ese paso es obligatorio para evitar
confundir artefactos de otro checkout con una regresión del código.

### 2.4 Cambios de arquitectura y composición

El objetivo refuerza el Feature-First Clean Architecture y modifica las
fronteras de dependencias:

| Área | Cambio observado en `from_first_day_2` | Riesgo de migración |
|---|---|---|
| Rutas | `AppRoute` pasa de `lib/app/router/app_route.dart` a `lib/shared/router/app_route.dart` | Todos los consumidores y sus pruebas deben moverse en una sola unidad coherente. |
| Navegación | Se agrega `IAppNavigator`, `appNavigatorProvider`, `GoRouterNavigator` y `routerOverrides()` | Las features no pueden importar `app/` ni `go_router`; el seam debe quedar enlazado en el composition root. |
| Dio | El provider compartido pasa a `lib/core/network/dio/dio_providers.dart`; `app/` solo enlaza el seam del interceptor | Evita el ciclo `core <-> auth`, pero requiere validar el grafo de Riverpod en boot. |
| Boot | `main.dart` fusiona `dioOverrides()` y `routerOverrides()`, valida seams y procesa errores de seguridad | Un binding faltante debe fallar rápido, no producir una aplicación parcialmente funcional. |
| Seguridad | El chequeo de jailbreak devuelve `Result`, registra el error y puede mostrar `DeviceSecurityBlockedScreen` | Requiere pruebas de Android/iOS y pruebas de boot con overrides. |
| Errores | La localización pasa de `shared/error/error_localizer.dart` a `lib/l10n/error_localizer.dart` | `shared` y `core` deben permanecer libres de `l10n` y Flutter. |
| Observabilidad | Se agrega `ILogger`, `DevLogger` y `loggerProvider` | Los notifiers y repositorios deben recibir el seam; no se deben dejar `debugPrint` permanentes. |
| Diseño | Se agregan `EmptyState`, `ErrorState`, `InfoChip`, `SkeletonList` y formatters | Cada componente necesita prueba y no puede introducir dependencia hacia features. |

Renombres y movimientos relevantes:

| Origen | Destino | Tratamiento |
|---|---|---|
| `lib/app/router/app_route.dart` | `lib/shared/router/app_route.dart` | `refactor(router): move route registry to shared kernel`; incluir consumidores y tests. |
| `lib/app/di/network/dio_provider.dart` | `lib/core/network/dio/dio_providers.dart` | Separar provider reusable de bindings de composition root. |
| `lib/shared/error/error_localizer.dart` | `lib/l10n/error_localizer.dart` | Mantener localización en UI y actualizar imports. |
| `lib/shared/exceptions/timeout_exception.dart` | `lib/shared/exceptions/app_timeout_exception.dart` | Actualizar barrel, `guard()` y pruebas de mapping. |
| `lib/shared/functions/offline_first_repository.dart` | `lib/shared/functions/online_first.dart` | Cambia API y agrega `DataOrigin`, write-through y guardas de frontera. |
| `lib/shared/interfaces/i_app_database.dart` | `lib/core/database/i_app_database.dart` | Mover tipos que exponen Sembast a infraestructura. |
| `features/auth/infrastructure/dtos/patient_dto*` | `core/network/contracts/patient_dto*` | El DTO pasa a ser contrato de transporte compartido. |
| DTOs clínicos en `features/auth` | `core/network/contracts/` | Auth y clinical history comparten el contrato wire. |
| `features/auth/infrastructure/repositories/auth_repository_impl.dart` | `auth_remote_repository_impl.dart` y `auth_local_repository_impl.dart` | Aplicar ISP y regla de una implementación por contrato. |
| `features/auth/presentation/screens/clinical_history_placeholder_screen.dart` | `features/clinical_history/presentation/screens/clinical_history_screen.dart` | Sustituir placeholder por bounded context real y eliminar goldens del placeholder. |

### 2.5 Persistencia y compatibilidad de datos

El objetivo no es un cambio cosmético de Sembast:

- `IAppDatabase` pasa a infraestructura.
- `AppDatabase` usa un codec AES-256-CBC encapsulado en
  `lib/core/database/sembast_codec.dart`.
- El cifrado se aplica también al factory de memoria usado por pruebas.
- La recuperación elimina la base solo ante un codec inválido o formato
  incompatible.
- `resetDatabase()` elimina el archivo y la clave de cifrado.
- Las escrituras de patient y clinical history usan transacciones.
- Clinical history usa store con claves string y expone solo las operaciones
  compartidas que necesita.
- Los providers de tablas se separan de las implementaciones en archivos
  `*_providers.dart`, regla verificada por CI.

Esto introduce una decisión de producto y seguridad: qué hacer con una base
local creada por `from_first_day_1` al instalar el binario nuevo. Antes de
fusionar el cambio se debe elegir una de estas políticas y dejar evidencia:

| Política | Uso | Requisito |
|---|---|---|
| Migración preservando datos | Si la cache local tiene valor clínico o regulatorio | Versionar schema/codec, probar upgrade desde una base fixture y tener rollback. |
| Invalidación y rehidratación | Si la cache es derivada del servidor | Detectar incompatibilidad, borrar solo cache incompatible, conservar sesión cuando sea seguro y rehidratar online. |
| Bloqueo de upgrade | Si no se puede garantizar integridad | Detener el despliegue y corregir antes de producción. |

No se debe aceptar que el `catch` que borra la base sea la única estrategia de
migración sin una prueba de instalación sobre datos existentes.

### 2.6 Red, contratos y política online-first

El objetivo añade `GET /user/clinical-history`, el provider inyectable de
endpoints y contratos compartidos en `core/network/contracts/`:

- `ClinicalHistoryDto` y sus seis sub-DTOs.
- `ClinicalHistoryListResponseDto`.
- `ClinicalHistoryMapper`.
- `PatientDto`, ahora compartido por auth y otros bounded contexts.
- `AppUris`/`IEndpointConfig` con `clinicalHistory`.

La política funcional queda definida así:

1. `loadClinicalHistories()` intenta remoto primero.
2. Solo `NetworkError` y `ServerUnreachableError` permiten fallback a cache.
3. `TimeoutError` no equivale a offline y no debe mostrar cache por defecto.
4. Una respuesta remota exitosa se escribe through a cache.
5. `refreshClinicalHistories()` siempre fuerza remoto y no hace fallback.
6. Si refresh falla con una lista visible, la lista se conserva y se emite un
   error transitorio para snackbar.
7. El datasource propaga excepciones; el repository las convierte a `Result`
   con `guard()`.
8. La feature no importa Dio ni agrega manualmente el Bearer; usa
   `httpServiceProvider` y el `AuthInterceptor`.

### 2.7 Auth y sesión

`from_first_day_1` tiene un repository de auth que mezcla remoto y local.
`from_first_day_2` lo separa:

- `IAuthRepository` queda remoto: login y refresh token.
- `ILocalAuthRepository` queda local: save, clear, reset y restore.
- Se agregan `CredentialLoginUseCase`, `ResetAccountUseCase` y inputs tipados.
- `RestoreSessionUseCase` coordina conectividad, credenciales, token, refresh
  y cache mediante `IUseCase`.
- `LocalAuthDatasourceImpl` persiste y limpia patient info, clinical history,
  token y credenciales.
- Logout limpia sesión; reset de cuenta ejecuta además el wipe total de base y
  clave.
- Login deja de caer silenciosamente a una sesión local.

Este cambio debe llegar con pruebas de regresión de auth. Clinical history no
puede importar `features/auth`; el único acoplamiento permitido y documentado
es que auth hidrata y limpia la cache mediante contratos del Shared Kernel.

### 2.8 Nueva feature `clinical_history`

El placeholder se convierte en un bounded context completo:

| Capa | Estado objetivo |
|---|---|
| `spec/` | `spec.md`, `domain.md`, `contracts.md`, `bdd.feature`, `tests.md`, `tasks.md` y `generated_api_contract.md`. |
| `domain/` | Contratos remoto/local, repository y dos use cases. No crea entidades nuevas. |
| `infrastructure/` | Datasource remoto, datasource local, repository online-first y logging. |
| `di/` | Cadena de providers hacia `httpServiceProvider`, endpoint, store y logger. |
| `presentation/notifiers/` | Estado sealed Freezed, notifier y error transitorio de refresh. |
| `presentation/screens/` | Loading skeleton, lista, empty state, retry, error state, snackbar y logout callback. |
| `presentation/widgets/` | Card M3 expandible con fecha, estado tipado y detalles opcionales. |
| Tests | Domain, infrastructure, presentation, BDD, integración y golden de screen/card. |

Los seis escenarios de aceptación son parte del contrato: carga remota,
lista vacía, refresh, cache offline, error sin cache y refresh offline que
conserva la lista.

### 2.9 Especificaciones inconsistentes que bloquean el merge

La implementación objetivo pasa sus pruebas actuales, pero sus artefactos SDD
no están completamente sincronizados:

- `tasks.md` separa `IClinicalHistoryRemoteDatasource` e
  `IClinicalHistoryLocalDatasource`.
- `generated_api_contract.md` todavía documenta una interfaz única y menciona
  `loadLocal()`/`storeLocal()` dentro del datasource remoto.
- `generated_api_contract.md` lista rutas antiguas como
  `i_clinical_history_datasource.dart` y `clinical_history_datasource_impl.dart`.
- El contrato generado menciona cinco escenarios en una sección, mientras
  `bdd.feature`, las pruebas y la integración contienen seis.
- El contrato generado fue marcado como generado y no debe editarse a mano.

Antes de implementar o publicar el stack se debe:

1. Corregir los seis artefactos fuente de la spec, especialmente `domain.md`,
   `tests.md`, `tasks.md` y `bdd.feature`.
2. Ejecutar de nuevo la extracción canónica D.0.5.
3. Verificar que `generated_api_contract.md` coincida con las rutas y firmas
   reales.
4. Pasar de nuevo el Phase-Gate.
5. Congelar la spec; cualquier cambio posterior reinicia el ciclo SDD/TDD.

## 3. Decisiones empresariales obligatorias antes de abrir PRs

Estas decisiones son gates de entrada, no tareas para resolver después del
merge:

| ID | Decisión | Responsable sugerido | Evidencia |
|---|---|---|---|
| D1 | `develop` actualizado de `from_first_day_1` es el baseline oficial | Tech lead | SHA y `git log` registrados en la descripción del PR raíz. |
| D2 | Se conserva `go_router ^17.5.0` y `riverpod_lint` | Arquitectura/Platform | Diff de `pubspec.yaml` y lock regenerado. |
| D3 | Política de upgrade de base local | Product + Security + Mobile | ADR o sección de release notes con prueba de upgrade. |
| D4 | Se elige squash merge o merge commit, no ambos | Engineering manager | Branch protection y comandos alineados. |
| D5 | Se corrige `generated_api_contract.md` antes de congelar la spec | Feature owner | Phase-Gate PASS y contrato generado consistente. |
| D6 | Se convierte integración en dispositivo en required check CI | QA/Platform | Job `Integration` en runner controlado, resultado requerido en branch protection y evidencia del dispositivo. |
| D7 | Los checks requeridos de branch protection coinciden con CI real | Repository admin | Lista de required status checks exportada de GitHub. |
| D8 | El warning de Swift Package Manager de `flutter_jailbreak_detection_plus` tiene seguimiento | Platform owner | Issue de dependencia y criterio de bloqueo para futura versión de Flutter. |
| D9 | Se acepta formalmente el núcleo atómico del PR 7 | Architecture board | Reporte de compilación aislada y decisión de no introducir adapters temporales. |
| D10 | Se corrige la matriz del reviewer AI y se activan CODEOWNERS/aprobaciones | Repository admin | PR 1, PR 5 y PR 8 más export de branch protection. |
| D11 | Los comandos AI soportan atomicidad, CI por `develop` y fallos reales antes del núcleo | Tech lead/AI owner | PR 5 fusionado y versión revisada de ambos comandos; PRs 1-4 pueden usar revisión humana controlada. |

## 4. Git Flow empresarial objetivo

### 4.1 Ramas permanentes

| Rama | Propósito | Entrada | Salida |
|---|---|---|---|
| `main` | Producción | Solo PR desde `release/*` o `hotfix/*` | Tag semver y despliegue. |
| `develop` | Integración | PRs de features, fixes, refactors, build, CI y docs | Candidato para release. |

Reglas de ambas ramas permanentes:

- Push directo bloqueado.
- `enforce_admins` habilitado.
- PR actualizado con la rama base antes de merge.
- CI obligatorio y verde.
- No se permite saltar un gate por ser administrador.
- No se hace force-push sobre ramas compartidas.
- Las ramas de trabajo se eliminan después del merge, salvo retención por
  auditoría.

### 4.2 Ramas temporales

Las ramas son type-prefixed y no incluyen números de stack:

| Tipo de cambio | Prefijo | Base habitual | Ejemplo |
|---|---|---|---|
| Funcionalidad | `feature/` | `develop` | `feature/clinical-history` |
| Corrección | `fix/` | `develop` | `fix/session-restore` |
| Refactor | `refactor/` | `develop` o rama previa del stack | `refactor/database-contracts` |
| Dependencias/build | `build/` | `develop` | `build/golden-test-config` |
| CI | `ci/` | `develop` | `ci/integration-gate` |
| Pruebas | `test/` | `develop` o rama previa | `test/clinical-history-acceptance` |
| Documentación | `docs/` | `develop` o rama previa | `docs/clinical-history-spec` |
| Mantenimiento AI | `chore/` | `develop` o rama previa | `chore/ai-workflow` |
| Release | `release/` | `develop` | `release/1.1.0` |
| Hotfix | `hotfix/` | `main` | `hotfix/session-crash-1.0.1` |

Los nombres de stack se mantienen en el cuerpo del PR y en una lista
`PR_BRANCHES`, no en el nombre de la rama. Esto sigue el contrato de
`super-pull-request.md`.

### 4.3 Convención de commits y títulos

Todo commit y título de PR debe estar en inglés, en modo imperativo y con
Conventional Commits:

```text
<type>(<scope>): <imperative subject>
```

Tipos permitidos: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`,
`ci`, `chore`, `style`, `revert` y `release`.

Reglas adicionales:

- El título del PR no lleva `PR 1:` ni numeración del stack.
- El título tiene como máximo 72 caracteres.
- El scope debe describir la capacidad: `database`, `network`, `auth`,
  `clinical-history`, `app`, `l10n`, `ci` o equivalente.
- Un commit no mezcla dependencias, infraestructura, UI y documentación sin
  una razón de arquitectura explícita.
- Los archivos generados se incluyen en el mismo commit que su fuente.
- Un test de una capacidad se incluye en la misma capacidad que el código que
  verifica; nunca se crea un PR de tests huérfanos que no compile.

### 4.4 Controles de GitHub requeridos para 10/10

La protección descrita en `README.md` es una buena base, pero `develop` con
cero aprobaciones no representa un estándar de empresa grande. Antes de
publicar la migración, el administrador del repositorio debe aplicar:

| Control | `develop` | `main` |
|---|---|---|
| Push directo | Bloqueado | Bloqueado |
| Force push y borrado | Bloqueados | Bloqueados |
| Branch up to date | Estricto antes de merge | Estricto antes de merge |
| Aprobaciones | Mínimo 1 reviewer distinto del autor | Mínimo 2 revisores, incluyendo Code Owner/release owner para cambios sensibles |
| CODEOWNERS | Requerido para `lib/core`, `lib/app`, `lib/shared`, CI y seguridad | Requerido para todo cambio de producción |
| Conversaciones | Todas resueltas | Todas resueltas |
| Dismiss stale reviews | Activado | Activado |
| Required checks | Analyze, Test, Goldens, builds, Gitleaks, coverage y CI adicional aprobado | Los mismos más Branch Source Gate y release checks |
| Merge | Squash aprobado por política o merge queue | Merge queue/release approval; nunca merge manual fuera de la política |

Una cuenta personal sin merge queue no debe presentarse como equivalente a una
plataforma empresarial. En ese caso se requiere una excepción documentada,
auto-merge solo después de checks verdes y un control humano equivalente. La
configuración real de GitHub, no `README.md`, es la fuente de verdad.

**Estado vigente (excepción de cuenta personal activa):** este repositorio se
mantiene con un solo humano, y GitHub bloquea la auto-aprobación. Por eso
`develop` opera con **0 aprobaciones requeridas** (config real) y `main` con 2
en config; el gate operativo es la matriz de required checks más el merge
humano explícito tras CI verde. El target de la tabla (≥1 reviewer en
`develop`, ≥2 en `main`) se activa cuando exista un segundo revisor/org — ver
`.github/REPOSITORY_GOVERNANCE.md`.

### 4.5 Política de dependencias

- **Pins del SDK:** el Flutter SDK pinneado en CI (`3.44.0`) fija versiones
  exactas (`intl 0.20.2` vía `flutter_localizations`; `test_api 0.7.11`,
  `matcher`, `meta`, `vector_math` vía `flutter_test`). Un constraint que las
  excluya rompe `flutter pub get`. Nunca editar el lock a mano; regenerar con
  `flutter pub get`.
- **No prerelease major de codegen:** el toolchain analyzer 13 (`build_runner
  2.16`, `riverpod_generator 4.0.8`) no tiene `freezed` estable compatible
  (3.2.5 exige analyzer <11; 3.2.6-dev.1 <13); solo `freezed 4.0.0-dev.3`
  (prerelease) lo soporta. Se difiere hasta que `freezed 4.0.0` estable exista
  (issue #62). El estado actual (analyzer 12 + freezed 3.2.6-dev.1 + riverpod
  4.0.4) es el último estado coherente sin prerelease y queda congelado.
- **Dependabot:** ignora `intl`, `test` y `freezed` (semver-major) — ver
  `.github/dependabot.yml`. Dependabot lee la config desde la **rama default
  (`main`)**; los cambios en `develop` solo se activan tras una release que los
  promueva (issue #63). Hasta entonces, los PRs regenerados se cierran
  manualmente.
- **compileSdk/minSdk:** se fijan explícitamente cuando un plugin exige más que
  el default de Flutter (p. ej. `flutter_secure_storage 11` → `compileSdk 37`).

La configuración externa de branch protection, reviewers y merge queue es una
precondición para abrir PR 1. PR 1 versiona el workflow, `CODEOWNERS` y la
política; no puede proteger retroactivamente su propio merge. Si la organización
no puede aplicar esos controles antes de PR 1, la migración queda en estado
preparado, no en estado 10/10.

Como `CODEOWNERS` de un PR no siempre gobierna retroactivamente ese mismo PR, el
administrador debe hacer un bootstrap de configuración sobre `develop` antes de
PR 1, o crear un PR 0 exclusivo de repository governance. Ese bootstrap no
contiene código de aplicación y debe tener su propia aprobación de
administración; PR 1 lo replica y lo deja versionado junto con el workflow.

El archivo `.github/CODEOWNERS` debe mapear, como mínimo:

```text
/lib/core/                 @org/platform-owners
/lib/app/                  @org/architecture-owners
/lib/shared/               @org/domain-owners
/lib/features/clinical_history/ @org/clinical-history-owners
/lib/features/auth/        @org/identity-owners
/test/                     @org/quality-owners
/integration_test/         @org/quality-owners
/.github/                  @org/platform-owners
/.ai/                      @org/engineering-productivity-owners
```

Los equipos son ejemplos de nombres corporativos y deben reemplazarse por
handles reales antes de activar la protección.

## 5. Procedimiento de migración por fases

### Fase 0. Congelación y baseline

1. Mantener ambos worktrees intactos como evidencia; no borrar ni resetear
   cambios existentes.
2. Registrar SHA, rama, `git status --short` y origen de cada checkout.
3. Confirmar que el `develop` de `from_first_day_1` es el más reciente del
   remoto.
4. Crear una rama temporal de migración desde ese `develop`, con nombre
   type-prefixed.
5. Crear un manifiesto de diferencias agrupado por capacidad y otro de archivos
   generados/artefactos que serán excluidos.
6. Escanear `.env`, `.env.*`, tokens, credenciales, secretos, claves privadas,
   `*.pem` y `*.key` antes de copiar cualquier parche.
7. No incluir `build/`, `.dart_tool/`, `Pods/`, `ephemeral/`,
   `local.properties` ni registradores generados por Flutter.

La rama no debe nacer de `from_first_day_2` porque ese checkout está detrás de
`develop`. Si se reutiliza `feature/clinical-history-extract`, debe actualizarse
de forma no destructiva y revisarse como una rama de trabajo, nunca como la
fuente de verdad.

### Fase 1. Reparación de especificación y contrato

1. Revisar los seis archivos SDD de clinical history.
2. Alinear nombres, interfaces, rutas, firmas y seis escenarios.
3. Ejecutar el API extractor y generar `generated_api_contract.md`.
4. Ejecutar el Phase-Gate y exigir `PASS`.
5. Congelar la spec después de `PASS`.

No se debe continuar con código si el Phase-Gate devuelve `FAIL` o `BLOCKED`.
La corrección debe hacerse y auditarse antes de escribir implementación.

### Fase 2. TDD y preparación local

Para cada capacidad nueva o migrada:

1. Leer la spec, arquitectura, providers, excepciones y reglas de wrappers.
2. Escribir los tests derivados de la spec antes de la implementación.
3. Ejecutar RED de forma local y registrar la razón esperada.
4. Crear stubs mínimos.
5. Ejecutar RED contra esos stubs.
6. Implementar la capacidad.
7. Ejecutar GREEN, `flutter analyze` y los tests de la capa.
8. Regenerar código y repetir GREEN.

El PR que se publica siempre debe terminar GREEN. RED es una etapa TDD local y
una evidencia de orden de desarrollo, no un estado admisible para commit
publicado o merge.

Regla estricta de commits:

- No se publica ningún commit que deje el proyecto sin compilar o con tests
  fallando de forma conocida.
- El ciclo RED puede existir en el worktree, pero se resuelve antes de ejecutar
  `super-commit.md`.
- Test y producción se commitean juntos cuando separarlos produciría un commit
  no compilable; esto coincide con la regla de
  `super-pull-request.md` de que los tests viajan con su código.
- Cada commit publicado debe tener evidencia de `flutter analyze` y del set de
  tests afectado; el PR completo además debe pasar la matriz CI.
- Si una migración requiere un commit transitorio no compilable, la estrategia
  actual no es válida: se debe crear primero un adapter compatible o mantener
  el cambio sin commitear.

### Fase 3. Commit atómico por rama

En cada rama del stack:

1. Preparar una lista explícita de archivos para esa capacidad.
2. Ejecutar `super-commit.md` desde el root del repositorio.
3. Mostrar la tabla de cambios y el plan de mensajes.
4. Esperar la confirmación explícita requerida por Step 3.5.
5. Stagear rutas explícitas, nunca `git add .` ni `git add -A`.
6. Revisar `git diff --cached --stat` antes de cada commit.
7. No usar `--no-verify`, `--amend`, force-push ni comandos destructivos.
8. Incluir add/modify/delete/rename intencionales.
9. Ejecutar la validación de la rama.
10. Hacer push solo después de la confirmación de push solicitada por el comando.

Para el PR atómico del núcleo, la lista de commits se debe ordenar por
dependencia y cada commit debe ser verde. No se debe dividir el núcleo en PRs
por `domain`, `infrastructure` y `presentation` solo para reducir el tamaño
visual del diff.

### Fase 4. PR apilado por ondas

1. Ejecutar `super-pull-request.md` para detectar `develop` y hacer fetch.
2. Clasificar cada archivo una sola vez.
3. Fusionar tests con producción y generated files con su fuente.
4. Auditar solapamientos entre PRs y dejar un log de autocorrecciones.
5. Ordenar capacidades por dependencias.
6. Ejecutar el comando por ondas, no sobre las 15 capacidades históricas a la
   vez.
7. Crear una rama por capacidad independiente desde `develop`, salvo el PR
   atómico que se crea después de integrar sus foundations.
8. Validar cada rama antes de crear o marcar listo el PR.
9. Publicar cada PR contra `develop` para que el workflow actual de CI se
   ejecute desde el primer momento.
10. Si por una dependencia real se crea una rama downstream temporal, el stack
   no puede tener más de dos niveles; retargetear a `develop` antes de pedir
   review o considerar el PR protegido.
11. Mergear una onda completa antes de comenzar la siguiente.
12. Nunca mergear dos PRs que modifiquen el mismo contrato en paralelo.

### Fase 5. Integración y release

1. Confirmar que todas las capacidades están en `develop` y que el árbol final
   coincide con el objetivo revisado.
2. Ejecutar validación completa incluyendo integración en dispositivo.
3. Crear `release/X.Y.Z` desde `develop`.
4. Abrir PR de release únicamente hacia `main`.
5. Esperar Branch Source Gate, CI completo y aprobación requerida.
6. Mergear; el release pipeline crea el tag anotado/protegido `vX.Y.Z` y
   despliega desde el commit fusionado, nunca desde un worktree local.
7. Hacer back-merge de release a `develop`.

Los hotfixes nacen de `main`, usan `hotfix/*`, entran a `main` por PR y luego se
hacen back-merge a `develop`.

## 6. Stack de PRs corregido para 10/10

El stack anterior de 15 PRs queda **descartado como plan operativo**. El
análisis empírico demuestra que sus PRs 2 a 14 no son estados compilables
independientes cuando se aplican al diff real. Una empresa grande no debe
mergear PRs que dejan `develop` roto ni esconder esa rotura detrás de una rama
downstream.

La estrategia corregida tiene un PR de controles previo, cinco PRs de foundation,
un PR atómico de implementación y un PR final de documentación. El PR 7 es
deliberadamente grande, pero es el único corte que conserva compilación porque
contiene el núcleo entrelazado de auth, clinical history, core, app y sus
pruebas. Los required checks deben existir antes de abrirlo.

Si el repositorio todavía no tiene branch protection, CODEOWNERS o merge queue
activos, se crea antes un **PR 0 de bootstrap de repository governance**. PR 0
no contiene código de aplicación, también usa `super-commit.md` y
`super-pull-request.md`, requiere aprobación del administrador y debe pasar la
validación disponible. Solo después se inicia PR 1.

| Orden | Título de PR | Rama sugerida | Base | Contenido principal |
|---|---|---|---|---|
| 0 opcional | `ci(repo): bootstrap repository governance` | `ci/repository-bootstrap` | `develop` | CODEOWNERS, branch protection, reviewers y merge queue; solo si faltan en GitHub. |
| 1 | `ci(repo): enforce enterprise merge gates` | `ci/enterprise-gates` | `develop` | Integration, format, coverage, Gitleaks, CODEOWNERS, required-check documentation y workflow hardening. |
| 2 | `build(deps): align project and platform baseline` | `build/deps-platform` | `develop` actualizado | Baseline de dependencias, `dart_test.yaml`, generación determinista y configuración de build independiente; los deep links quedan para PR 7. |
| 3 | `feat(models): add shared domain models` | `feature/shared-models` | `develop` actualizado | Modelos Shared Kernel estrictamente aditivos, `ClinicalHistoryStatus` y tests de modelos que no exijan el núcleo nuevo. |
| 4 | `feat(design-system): add reusable state components` | `feature/design-system-primitives` | `develop` actualizado | `EmptyState`, `ErrorState`, `InfoChip`, `SkeletonList`, formatters, colores y tests. |
| 5 | `chore(ai): align engineering workflow commands` | `chore/ai-workflow` | `develop` actualizado | `.ai/commands`, orchestrators, skills y reglas AI; sin mezclar código de aplicación. |
| 6 | `docs(clinical-history): freeze specification and migration policy` | `docs/clinical-history-spec` | `develop` actualizado | Spec corregida, API contract regenerado, gobernanza y documentación verdadera para el estado pre-feature. |
| 7 | `refactor(architecture): migrate auth and clinical history boundaries` | `refactor/clean-architecture-core` | `develop` con PRs 1-6 | Núcleo atómico completo: errors, ports, database, network contracts, auth, app seams, clinical history, route, tests y fixtures. |
| 8 | `docs(repo): publish final architecture and release controls` | `docs/enterprise-governance` | `develop` después del PR 7 | `GIT_FLOW.md`, README, AGENTS, MD, LEARN, release/rollback runbook y documentación final coherente con código ya fusionado. |

Reglas de esta tabla:

- PR 7 no se subdivide por carpeta. `super-pull-request.md` debe recibir una
  excepción documentada de atomicidad para agrupar sus grupos entrelazados.
- PR 1 no se mezcla con AI ni con documentación funcional; solo contiene
  controles CI/CD y su prueba/configuración.
- PR 8 no contiene código de aplicación; documenta únicamente un estado que ya
  pasó PR 1 y PR 7.
- Cada PR termina compilable, testeable y revisable contra `develop`.
- Nunca se publican 15 ramas simultáneas ni un stack de más de dos niveles.

### 6.1 Ondas de ejecución

| Onda | PRs | Regla de merge |
|---|---|---|
| Bootstrap | 0 opcional | Si faltan controles externos, fusionarlo antes de PR 1; si ya existen, registrar evidencia y omitirlo. |
| Controls | 1 | Se fusiona primero y deja activos los required checks antes de cualquier cambio funcional. |
| Foundation | 2, 3, 4 y 5 | PRs independientes, uno a la vez contra `develop`; esperar CI y merge antes de abrir el siguiente que dependa de él. |
| Specification | 6 | Se abre contra `develop` ya actualizado; Phase-Gate PASS antes del PR 7. |
| Atomic implementation | 7 | Un único PR funcional; todos sus commits se validan en orden y el PR recibe revisión por subáreas. |
| Final documentation | 8 | Solo documenta controles y estado ya verificado después del PR 7. |

`super-pull-request.md` se ejecuta una vez por onda o por PR, no sobre todo el
worktree de 380+ archivos de una sola vez. Si el comando propone más grupos
para el PR 7, se aplica la auditoría de compilación y se conserva la capacidad
atómica documentada.

### 6.2 Commits atómicos esperados por PR

Los mensajes siguientes son el plan inicial. `super-commit.md` debe confirmar
la lista exacta de archivos y no debe inventar commits de tests que dejen una
rama en RED.

#### PR 0 opcional: bootstrap de repository governance

```text
ci(github): bootstrap code owners and branch protection
ci(github): configure merge queue and required reviewers
test(ci): verify repository governance configuration
```

Solo se crea si los controles externos no existen. Si se crea, se revisa y se
fusiona antes de PR 1.

#### PR 1: CI and enterprise gates

```text
ci(github): add integration and format quality gates
ci(github): require coverage and security status checks
ci(github): add code owners and branch policy metadata
ci(github): pin actions and minimize workflow permissions
test(ci): verify workflow anti-masking rules
```

Este PR debe fusionarse antes de PR 2 y debe dejar activos sus required checks.

#### PR 2: baseline de proyecto

```text
build(deps): preserve current dependency baseline
build(test): configure deterministic golden selection
build(platform): align independent platform configuration
test(architecture): verify test harness gates
```

`go_router ^17.5.0` y `riverpod_lint` se conservan. Si no hay una diferencia
real de dependencias respecto a `develop`, no se crea un commit artificial.

#### PR 3: Shared Kernel aditivo

```text
feat(models): add typed clinical history status
test(models): cover shared model invariants
```

No mover en este PR `IAppDatabase`, `IAppNavigator`, `ILogger`, DTOs ni
excepciones no retrocompatibles; pertenecen al núcleo atómico.

#### PR 4: design system

```text
feat(design-system): add reusable empty error and skeleton states
feat(design-system): add clinical display formatters
test(design-system): cover reusable UI primitives
```

Los componentes deben depender solo de Flutter y `intl`, nunca de `core` o de
una feature.

#### PR 5: AI workflow

```text
chore(ai): align commit workflow command
chore(ai): align pull request workflow
docs(ai): document workflow invariants
```

Este PR no debe introducir archivos de `lib/` ni `test/` funcionales. Los
comandos se pueden leer desde el checkout objetivo antes del merge, pero el PR
formal debe dejar una copia versionada y revisada. Debe añadir explícitamente
al workflow AI:

- Auditoría de compilación antes de aceptar el split automático.
- Excepción documentada para el núcleo atómico del PR 7.
- Límite de dos niveles de stack.
- Required CI contra `develop` antes de review/merge.
- Prohibición de publicar commits RED.
- Error real ante fallo de `build_runner`; nunca ocultarlo con `|| true`.
- Override de la recomendación de 400 líneas solo con reporte de compilación y
  aprobación del Architecture Board para PR 7.
- Matriz de arquitectura compatible con `MD/APP_ARCHITECTURE.md` y las Rules
  1-28 del repositorio.
- Reviewer AI alineado con squash merge, revisión secuencial y la misma matriz
  de arquitectura; no puede usar `--merge` si la política oficial es squash.

#### PR 6: specification and migration policy

```text
docs(clinical-history): correct feature contracts and scenarios
docs(repo): document database upgrade and rollback policy
```

`generated_api_contract.md` se regenera desde la spec corregida; nunca se edita
manualmente. Este PR debe declarar que la feature aún está pendiente si el
código todavía no está en `develop`.

#### PR 7: clean-architecture core atomic PR

```text
refactor(core): introduce typed error and observability boundaries
refactor(database): migrate encrypted persistence and session stores
feat(network): add shared clinical transport contracts
refactor(auth): split remote and local session repositories
feat(clinical-history): implement online-first feature layers
refactor(app): wire routing security and dependency seams
test(architecture): enforce final dependency and barrel rules
test(clinical-history): add unit widget BDD integration and golden coverage
```

Estos commits son internos del mismo PR. Cada uno debe ser ordenado por
dependencia, contener tests y producción juntos cuando sea necesario y pasar la
validación definida en la sección 8.2 antes de publicarse.

La lista de commits es una propuesta de unidades de revisión, no una garantía
de que cada corte sea compilable. Antes de publicar PR 7 se ejecuta una prueba
de replay commit a commit en un sandbox con `build.yaml`. Si un commit falla
por una dependencia que solo aparece en el siguiente commit, se fusiona con
esa dependencia o se convierte el núcleo en un único commit atómico. Nunca se
publica la secuencia propuesta sabiendo que un commit intermedio está roto.

El tamaño del PR 7 no reduce el estándar de revisión. Su PR body debe incluir:

- Manifiesto completo de archivos agrupado por `errors`, `database`, `network`,
  `auth`, `app`, `clinical_history`, tests y generated files.
- Diagrama de dependencias y reporte de la auditoría de compilación aislada.
- Tabla de commits, cada uno con su validación GREEN.
- Matriz de reviewers: architecture, database/security, auth/network,
  clinical-history/QA y platform/release.
- Evidencia de unit/widget, BDD, goldens, integración, builds, coverage y
  Gitleaks.
- Plan de migración de base local, rollback y riesgos conocidos.

El PR 7 se revisa por commits y por áreas usando CODEOWNERS, pero se fusiona
como una sola unidad funcional. No se debe reducir artificialmente su alcance
para obtener PRs pequeños que rompan `develop`.

#### PR 8: final documentation

```text
docs(repo): publish final architecture documentation
docs(repo): publish release and rollback runbook
docs(repo): version enterprise Git Flow policy
```

README, AGENTS, MD y LEARN se actualizan después de que el PR 7 haya pasado,
para que no describan un estado futuro no compilado.

### 6.3 Grafo de dependencias corregido

No se usa un stack de 15 niveles:

```text
develop
  |
  +-- PR 0 ci/repository-bootstrap [solo si faltan controles]
  |
  +-- PR 1 ci/enterprise-gates       [merge + CI first]
  +-- PR 2 build/deps-platform       [merge + CI]
  +-- PR 3 feature/shared-models     [merge + CI]
  +-- PR 4 feature/design-system-primitives [merge + CI]
  +-- PR 5 chore/ai-workflow         [merge + CI]
  +-- PR 6 docs/clinical-history-spec [Phase-Gate PASS]
  |
  +-- PR 7 refactor/clean-architecture-core [unico núcleo funcional]
          |
          +-- PR 8 docs/enterprise-governance
```

El PR 1 se abre y mergea primero para que el resto tenga gates empresariales.
Los PRs 2 a 6 se abren y mergean contra `develop` de forma secuencial para
mantener el baseline actualizado. El PR 7 se crea únicamente cuando todos sus
fundamentos están en `develop`. El PR 8 se abre después del núcleo.

Si se necesita usar branches apiladas por una dependencia operacional, se
permite solo `parent -> child`; el child se retargetea a `develop`, obtiene CI
completo y se revisa antes de merge. `$PR_BRANCHES` nunca debe contener una
cadena de más de dos ramas activas.

## 7. Uso obligatorio de `super-commit.md`

### 7.1 Antes de comprometer una rama

Ejecutar el contenido de
`from_first_day_2/.ai/commands/super-commit.md` desde el repositorio de la
rama. No reemplazarlo por un `git commit` manual sin reproducir sus controles.

El resultado esperado del comando es:

| Paso | Control obligatorio |
|---|---|
| 1 | Tabla visible de cambios, diff estadístico, diff completo y últimos commits. |
| 2 | Escaneo de secretos; si aparece una coincidencia, detener y preguntar. |
| 3 | Agrupación por intención: `feat`, `fix`, `refactor`, `test`, `docs`, `build`, `ci`, `chore`. |
| 3.5 | Confirmación explícita del plan de commits. |
| 4 | Stage explícito por ruta y commits semánticos, sin `git add .`, `--no-verify`, `--amend` o force-push. |
| 5 | Push solo después de confirmación explícita y resumen de commits. |

Para una rama apilada, el alcance de la tabla debe ser solo la capacidad de
esa rama. Si aparecen archivos de otra capacidad, se detiene el proceso y se
corrige el manifiesto; no se "aprovecha" el staging global.

### 7.2 Reglas de seguridad

- Nunca commitear `.env`, credenciales, tokens reales, certificados privados,
  claves o dumps de producción.
- Los fixtures pueden usar tokens sintéticos y explícitamente no válidos.
- No incluir datos clínicos reales en fixtures, screenshots o goldens.
- No ocultar cambios con `git stash` destructivo, reset hard o checkout sobre
  modificaciones ajenas.
- Si un hook falla, corregir la causa; no saltarlo.
- Si un commit ya fue publicado, crear un nuevo commit correctivo; no amend.

## 8. Uso obligatorio de `super-pull-request.md`

### 8.1 Análisis y clasificación

El comando debe:

1. Detectar `develop`; si no existe, detenerse y pedir base explícita.
2. Hacer fetch de la base.
3. Analizar status, diff contra base y log.
4. Clasificar cada archivo en un solo grupo.
5. Fusionar tests con producción y generated files con su fuente.
6. Auditar solapamientos entre PRs y dejar un log de autocorrecciones.
7. Ordenar capacidades por dependencias.

Antes de invocarlo, la capacidad seleccionada debe estar materializada en la
rama mediante commits preparados por `super-commit.md`. El Step 2 del comando
calcula principalmente `git diff $BASE..HEAD`; no se debe confiar en que el
comando detectará correctamente las modificaciones no commiteadas del worktree.
Nunca se le entrega el worktree completo para que decida por sí solo entre 15
PRs; se le entrega el manifiesto de una onda o del PR 7 atómico.

El Step 4.4 de `super-pull-request.md` describe cómo aplicar los commits, pero
no autoriza a saltarse `super-commit.md`. La creación real de cada commit se
delegará a `super-commit.md`; el comando de PR solo conserva la clasificación,
el orden, la validación y la publicación del stack.

Aplicación específica a este cambio:

| Regla del comando | Aplicación |
|---|---|
| `.github/workflows/**`, `codecov.yml`, `CODEOWNERS` y tests de workflow | PR 1, antes de cualquier cambio funcional. |
| `lib/shared/models/**` con tests de modelos | PR 3, solo si el cambio es aditivo y compila sobre `develop`. |
| `lib/design_system/**` con tests de componentes | PR 4. |
| `*.g.dart` y `*.freezed.dart` | Mismo PR que su fuente. |
| `.ai/**` | PR 5, sin mezclar código de aplicación. |
| `lib/features/clinical_history/spec/**` | PR 6, con Phase-Gate y API contract regenerado. |
| `lib/core/database/**`, `lib/core/network/**`, `lib/features/auth/**` | PR 7, porque sus contratos y consumidores cambian juntos. |
| `lib/features/clinical_history/{domain,infrastructure,presentation}/**` | PR 7, no separados por carpeta; la auditoría empírica demuestra que son parte del núcleo. |
| `integration_test/**`, `test/bdd/**`, goldens y tests de arquitectura finales | PR 7, junto con el código que hacen compilable. |
| `GIT_FLOW.md`, `MD/**`, `AGENTS.md`, `README.md`, `LEARN.md` | PR 8, después del código final. |

### 8.1.1 Excepción de atomicidad obligatoria

Las reglas genéricas R9b, R10 y R11 de `super-pull-request.md` separan domain,
infra y presentation. En este snapshot esa separación mecánica es incorrecta.
Antes de aceptar el split automático se debe ejecutar una auditoría de
compilación:

1. Aplicar cada capability propuesta sobre una copia limpia de `develop`.
2. Ejecutar `flutter analyze` y el set de tests afectado.
3. Registrar errores por capability y por dependencia faltante.
4. Si una capability falla por contratos que pertenecen a otra, fusionar ambas
   en una capacidad atómica y documentar la razón.
5. Repetir hasta que cada PR público sea compilable y verde.

Para esta migración, la excepción ya está justificada para PR 7 por la
evidencia de la sección 1.1. No se debe auto-corregir el overlap removiendo
archivos que el núcleo necesita; el owner de esos archivos es el PR atómico.

### 8.2 Validación por PR

La validación mínima de cada PR de código es:

```bash
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
# Ejecutar solo si cambiaron archivos .arb:
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage --exclude-tags golden
flutter test --tags golden
```

No ejecutar `flutter gen-l10n` si no cambió ARB solo para generar ruido; sí se
debe ejecutar al cambiar `app_en.arb` o `app_es.arb`. Los errores de
`build_runner` no se ignoran: el `|| true` del comando de automatización no
puede convertir una generación fallida en un PR verde.

El comando de generación debe ejecutarse desde el root que contiene
`build.yaml`. Ese archivo configura `json_serializable`; omitirlo en un sandbox
puede producir un falso diff en `.g.dart` y una falsa alarma de generación.
Después de generar, se verifica que no existan cambios no explicados en los
archivos generados.

Validaciones adicionales según contenido:

| Cambio | Gate adicional |
|---|---|
| `integration_test/**` o navegación | `flutter test integration_test/clinical_history_integration_test.dart -d macos` y equivalente disponible. |
| `android/**` | `flutter build apk --debug`. |
| `ios/**` | `flutter build ios --no-codesign`. |
| `pubspec.*` | `flutter pub get`, lock revisado y build de plataformas. |
| CI/configuración | Test de workflow y validación sintáctica del YAML. |
| Solo AI/docs | Format/analyze solo si hay Dart; validación de enlaces, rutas y consistencia documental. |

Un commit interno del PR 7 debe pasar al menos `dart format`, `flutter analyze`
y los tests de su subárea. El PR completo debe pasar la suite no-golden,
goldens, builds e integración aplicable antes de ser publicado.

Si falla la validación:

- Analyzer: usar `app-agent-fix-analyzer-issues`.
- Tests: usar `app-agent-fix-tests`.
- Código generado: corregir la fuente y regenerar.
- Máximo cinco iteraciones de reparación por PR.
- Máximo tres iteraciones globales de revalidación.
- Si se supera el límite, detenerse y escalar, sin forzar el merge.

Después de ejecutar todo el stack, volver a validar todas las ramas en orden y
registrar una tabla final de PASS/FAIL antes de publicar.

### 8.3 Publicación y merge del stack

- Cada PR público apunta a `develop`; el comando no debe dejar como mergeable un
  PR cuyo base sea una rama intermedia.
- `super-pull-request.md` se ejecuta por PR u onda, con `$PR_BRANCHES` de una o
  dos ramas como máximo.
- Se hace push secuencial y se crea cada PR con `gh pr create`.
- No se mergean dos PRs que compartan contratos en paralelo.
- Si se necesita un child temporal, se retargetea a `develop`, se verifica que
  el diff se redujo a su capacidad y se espera CI completo antes de review.
- PR 7 no se abre hasta que PRs 1 a 6 estén fusionados en `develop`.
- PR 8 no se abre hasta que PR 7 tenga CI verde y merge aprobado.
- El workflow actual de CI solo escucha PRs cuyo base sea `develop` o `main`.
  Un PR downstream apuntando temporalmente a otra rama del stack no debe
  considerarse protegido por required checks hasta ser retargeteado a
  `develop` y recibir una ejecución completa de CI.

## 9. TDD, SDD y BDD obligatorios

### 9.1 Flujo Spec-Local

Para `clinical_history`, el flujo debe ser el orchestrator de
`from_first_day_2`, no implementación manual fuera del flujo:

```text
User story
  -> spec definition
  -> 6 artefactos SDD
  -> Phase-Gate PASS
  -> API extraction D.0.5
  -> package/wrapper audit D.0.6
  -> domain, infra, presentation, integration y BDD tests first
  -> hard-stop de las 5 carpetas de tests
  -> stubs RED
  -> implementación GREEN por capa
  -> goldens D.8.5
  -> barrels y navegación D.10
  -> direct-import audit D.10.5
  -> integración real en dispositivo D.10.6
  -> verificación final y documentación
```

No se permite afirmar que una feature está terminada porque sus pruebas fueron
creadas después. Si se está haciendo retrofit de código ya existente, se debe
reconstruir la evidencia: spec corregida, tests derivados, RED esperado, GREEN
y supervisor por fase.

En el PR 7, "tests first" describe el orden de trabajo y no obliga a publicar
un PR o commit rojo. La secuencia correcta es:

1. Escribir todos los tests desde la spec en un worktree que todavía puede no
   compilar.
2. Ejecutar la comprobación RED y conservar su evidencia en el reporte de la
   fase, no en la rama compartida.
3. Implementar por capas y completar el GREEN.
4. Agrupar test y producción en commits verdes, o introducir un adapter
   temporal si un commit independiente es indispensable.
5. Ejecutar `super-commit.md` solo después de que el commit propuesto sea
   compilable y pase sus tests.

El resultado es TDD real con historia Git limpia: ningún commit publicado en
PR 7 puede depender de que un commit posterior lo arregle.

### 9.2 Criterios TDD por capa

| Capa | RED esperado | GREEN requerido |
|---|---|---|
| Domain | Use cases stub lanzan `UnimplementedError` | Delegan al repository y cubren éxito/fallo. |
| Infrastructure | Datasources/repository stub no cumplen contrato | Remote parsea DTO, local adapta store y repository usa `guard`/`fetchOrFallback`. |
| Presentation | Notifier stub no produce estados y screen no existe | Estados Initial/Loading/Loaded/Failure, refresh conserva lista y UI localizada. |
| Golden | Fixture inexistente o desactualizada | Loading, loaded, empty y card collapsed/expanded deterministas. |
| BDD | Step definitions incompletas | Seis escenarios de `bdd.feature` pasan. |
| Integration | Ruta o boot aún no wired | Seis escenarios pasan en dispositivo macOS, Android o iOS. |

### 9.3 Reglas de tests

- Los tests no hacen HTTP real.
- Las dependencias se sustituyen con overrides de Riverpod.
- Se mockean interfaces (`IDioWrapper`, stores, repositories), no paquetes
  externos ni implementaciones concretas.
- Datasources dejan escapar excepciones tipadas.
- Repositories convierten excepciones en `Result` usando `guard()`.
- Los notifiers solo coordinan use cases y estados; no contienen política de
  negocio.
- Las pantallas no importan infraestructura ni `go_router`.
- Todo use case tiene caso feliz y caso de fallo.
- Toda modificación de Shared Kernel actualiza mapper, serializer, store y
  round-trip tests de todos sus consumidores.

## 10. CI/CD y gates de calidad

### 10.1 CI existente observado

`.github/workflows/ci.yml` se ejecuta en PRs hacia `develop` y `main`, y en
pushes a esas ramas. La matriz actual es:

| Job | Runner | Comando/función | Gate |
|---|---|---|---|
| Analyze | Ubuntu | `flutter pub get`, `flutter analyze` | Cero issues. |
| Test | Ubuntu | `flutter test --coverage --exclude-tags golden` | Unit, widget, arquitectura, BDD no-golden y Codecov. |
| Test Goldens | Ubuntu | `flutter test --tags golden` | Goldens deterministas; depende de Analyze. |
| Build iOS | macOS | `flutter build ios --no-codesign` | Compilación iOS; depende de Analyze. |
| Build Android | Ubuntu | `flutter build apk --debug` | Compilación Android; depende de Analyze. |
| Gitleaks | Ubuntu | Scan de historia completa con `fetch-depth: 0` | Cero secretos detectados. |
| Branch Source Gate | Ubuntu, solo PR a `main` | Solo acepta heads `release/*` o `hotfix/*` | Evita feature directo a producción. |

Controles adicionales que deben conservarse:

- Flutter fijado en `3.44.0`.
- `permissions: contents: read` como mínimo.
- Concurrency por ref con cancelación de ejecuciones obsoletas.
- Cache de Flutter y CocoaPods donde corresponda.
- Builds desacoplados de Test y dependientes de Analyze para que una regresión
  de compilación no quede escondida por el orden de jobs.
- Test principal excluye goldens y Test Goldens los ejecuta de forma explícita.
- Codecov no debe bloquear por una caída de su servicio, pero el patch coverage
  y el threshold acordado sí deben revisarse.
- Dependabot abre a `develop`; patch/minor puede auto-mergearse, major requiere
  revisión humana.

### 10.2 Gaps empresariales que se deben resolver

1. El README habla de seis checks para `develop`, mientras una sección de
   `LEARN.md` menciona cinco y omite Gitleaks. La fuente de verdad debe ser la
   configuración real de branch protection en GitHub. Los nombres requeridos
   deben coincidir exactamente con los jobs.
2. El workflow actual no ejecuta `integration_test/` en un dispositivo. El
   orchestrator sí exige ejecución real y la validación local de este snapshot
   pasó en macOS. Para obtener 10/10 se debe agregar un job de integración en
   `macos-latest` o un runner de dispositivo controlado y convertirlo en
   required check. La evidencia manual no sustituye un gate CI para un cambio
   de producción.
3. Los pushes a ramas de trabajo tampoco disparan este workflow; la protección
   efectiva ocurre al abrir o retargetear el PR hacia `develop`/`main`. El
   proceso debe registrar la ejecución de CI de cada capacidad antes del merge;
   PR 1 debe evitar que el pipeline dependa solo de pushes a ramas permanentes.
4. iOS se compila sin firma y Android en debug. Eso valida compilación, no
   distribución. Release signing, SBOM, escaneo de dependencias y smoke tests
   de release deben vivir en un pipeline protegido separado.
5. El warning de `flutter_jailbreak_detection_plus` sobre Swift Package
   Manager debe tener issue, owner y criterio de actualización antes de que
   una futura versión de Flutter lo convierta en error.
6. El CI no ejecuta `dart format` como gate explícito. PR 1 debe añadirlo al job
   de análisis o crear un check dedicado.
7. `fail_ci_if_error: false` permite que falle el upload de Codecov sin fallar
   el job. El upload puede seguir siendo tolerante a una caída externa, pero
   debe existir un check interno de cobertura y un status de patch coverage
   requerido para que una reducción de cobertura sí bloquee el merge.
8. `develop` documenta cero aprobaciones. Para 10/10 se deben exigir
   CODEOWNERS, al menos una aprobación independiente y resolución de todas las
   conversaciones en `develop`; `main` requiere la política reforzada de la
   sección 4.4.

### 10.3 Gate por entorno

| Entorno | Requisito para avanzar |
|---|---|
| Desarrollo local | Analyze, unit/widget, BDD local, goldens afectados e integración en dispositivo para cambios de feature. |
| PR público a `develop` | Commits semánticos, diff sin secretos/artefactos, validación local y CI del PR verde. |
| Merge a `develop` | Todos los required checks actuales, revisión de alcance/arquitectura/tests y stack en orden. |
| Release candidate | Suite completa, upgrade de base local, builds de plataforma, revisión de seguridad y aprobación de release. |
| Merge a `main` | `release/*` o `hotfix/*`, Branch Source Gate, checks completos, aprobación y plan de rollback. |

### 10.4 CI objetivo para la nota 10/10

PR 1 debe dejar explícitamente estos checks, con nombres estables y registrados
en branch protection:

| Check requerido | Responsabilidad |
|---|---|
| `Analyze` | `flutter pub get`, `dart format --output=none --set-exit-if-changed lib test integration_test`, `flutter analyze`. |
| `Test` | Unit/widget/architecture/BDD no-golden y generación de coverage. |
| `Test Goldens` | Goldens en Linux con tags y fonts deterministas. |
| `Integration` | Los escenarios de `integration_test` en runner macOS/dispositivo controlado. |
| `Build Android` | APK debug para PR y artefacto release en pipeline protegido. |
| `Build iOS` | iOS no-code-sign para PR y build firmado separado para release. |
| `Coverage` | Patch/project coverage y no regresión del threshold acordado. |
| `Gitleaks` | Historia completa, sin secretos. |
| `Branch Source Gate` | Solo en PRs a `main`, heads `release/*` o `hotfix/*`. |

Los nombres de los jobs, los nombres de los required checks y la documentación
deben ser idénticos. Un check ausente, opcional o con nombre distinto invalida
la afirmación de que el PR está protegido.

PR 1 también debe pinnear GitHub Actions a SHA inmutable, mantener Dependabot
para actualizar esos SHAs y asignar permisos por job con mínimo privilegio.
`contents: write` y `pull-requests: write` solo pueden existir en el job de
auto-merge que realmente los necesita; Analyze, Test, Goldens, builds y
Gitleaks deben permanecer read-only.

El job `Integration` debe descubrir los archivos de
`integration_test/` y ejecutarlos individualmente en el runner controlado, tal
como requiere la caveat de macOS del proyecto. Cada archivo debe fallar el job
si falla; no se acepta `|| true`, tests omitidos silenciosamente ni un job que
siempre termine verde sin ejecutar casos.

## 11. Consistencia del merge strategy

Hay una contradicción que debe resolverse antes de ejecutar el reviewer:

- `README.md`, `LEARN.md`, `MD/APP_IMPORTANT_INFO.md` y
  `super-pull-request.md` declaran squash merge, con
  `squash_merge_commit_title: PR_TITLE`; por eso el título del PR se convierte
  en el commit de `develop`/`main`.
- `super-pull-request-reviewer.md` describe `gh pr merge --merge` y dice que no
  se use squash para conservar commits.

Para este repositorio, la política recomendada es squash por PR:

1. Mantiene un commit limpio por capacidad en `develop`.
2. Hace que el título Conventional Commit sea auditable.
3. Reduce ruido de commits intermedios RED/GREEN y reparaciones.
4. Es coherente con la documentación de branch protection existente.

Antes del primer merge, se debe alinear el reviewer con esta decisión o
modificar formalmente toda la política para usar merge commits. No se debe
mezclar squash en unos PRs y merge commit en otros. Aunque se use squash al
final, los commits atómicos internos siguen siendo obligatorios para revisión,
rollback y diagnóstico antes del merge.

También existe una tensión entre `AGENTS.md` y los comandos AI: `AGENTS.md`
exige confirmar el comando Git exacto antes de ejecutarlo, mientras
`super-pull-request.md` ordena ejecutar el pipeline sin preguntas intermedias.
El protocolo 10/10 es:

1. Presentar al tech lead el lote exacto de comandos Git que el pipeline va a
   ejecutar, con sus ramas y objetivos.
2. Obtener una autorización explícita para ese lote.
3. Mantener las confirmaciones propias de `super-commit.md` Step 3.5 y Step 5,
   y la confirmación de publicación de `super-pull-request.md` Step 5.1.
4. No ejecutar comandos Git adicionales fuera del lote autorizado.
5. Si el equipo interpreta la regla de `AGENTS.md` literalmente por comando,
   actualizar primero `super-pull-request.md`; no ignorar la regla por
   automatización.

## 12. Revisión humana y criterios de aprobación

El reviewer debe evaluar cada PR en ocho gates:

| Gate | Pregunta |
|---|---|
| 1. Alcance | ¿La descripción coincide con todos los archivos y el diff? |
| 2. Unrelated changes | ¿No hay archivos de otra capacidad, artefactos o generated files sin fuente? |
| 3. Arquitectura | ¿Se conservan las direcciones `shared -> core -> feature -> app` y aislamiento de features? |
| 4. Tests | ¿Cada cambio funcional tiene test adecuado y el test se integra en su PR? |
| 5. Ejecución | ¿Analyze, tests, goldens, builds e integración aplicable pasan? |
| 6. Merge readiness | ¿Está actualizado, sin conflictos, con CI verde y aprobación requerida? |
| 7. Commit quality | ¿Cada commit publicado es compilable, testeable y no depende de un commit rojo posterior? |
| 8. Atomicity | ¿La separación respeta la auditoría de compilación y no partió el núcleo indivisible? |

Infraestructura de base de datos, auth, seguridad, presentación y nuevas
dependencias requieren revisión humana aunque el reviewer automático no
encuentre fallos. No se autoaprueban migrations, cambios de cifrado, cambios de
interceptor, UI crítica ni código que introduzca dependencia externa.

### 12.1 Revisión del reviewer AI

`super-pull-request-reviewer.md` contiene reglas de arquitectura que no son
compatibles literalmente con este proyecto: describe `infrastructure` como si
solo pudiera importar `domain` y permite que `presentation` importe
`infrastructure`, mientras las reglas reales exigen:

```text
shared              -> solo shared / Dart puro
core                -> shared y core; nunca features ni app
features/domain     -> shared y anotaciones permitidas
features/infra      -> own domain + shared + core
features/presentation -> own di + domain + shared + design_system + l10n
app                 -> composition root
```

Antes de usar el reviewer para aprobar PR 1, PR 7 o PR 8 se debe corregir esa
matriz en PR 5 o dejar una excepción de revisión aprobada. Mientras PR 5 no
esté fusionado, PRs 1 a 4 requieren revisión humana explícita usando la matriz
de este documento y no pueden ser aprobados por el reviewer AI desactualizado.
Un reviewer que marca como válida una dependencia prohibida no es un gate 10/10.

## 13. Rollback y operación

### Rollback de código

- Si falla un PR antes de merge, detener ese branch y reparar sin alterar
  `develop`.
- Si falla después de merge a `develop`, abrir `fix/*` desde `develop`; no
  reescribir historia.
- Si falla en producción, crear `hotfix/*` desde `main` o revertir el PR
  squashado con un commit `revert(...)` y su PR correspondiente.
- Documentar el incidente, el SHA afectado y si se requiere back-merge.

### Rollback de datos locales

- No usar `resetDatabase()` como recuperación genérica de sesión.
- Logout limpia datos de sesión; reset de cuenta es el único flujo de wipe total.
- Si el codec/schema no es compatible, aplicar la política D3 aprobada.
- Probar downgrade o reinstalación sobre datos fixture antes del release.
- No registrar tokens, credenciales ni contenido clínico en logs.

## 14. Definition of Done de la migración

La migración solo está completa cuando se cumplen todos los puntos:

- El código está basado en el `develop` correcto y no en el HEAD antiguo de
  `from_first_day_2`.
- La regresión de dependencias está resuelta y documentada.
- La spec de clinical history tiene seis artefactos válidos y el contrato
  generado coincide con las interfaces reales.
- La auditoría de compilación de capabilities está adjunta y demuestra por qué
  PR 7 es el único núcleo atómico.
- Phase-Gate y Spec-Local TDD fueron ejecutados sin saltos.
- Domain, infrastructure, presentation, BDD, golden e integration tests están
  presentes y pasan.
- `flutter analyze` devuelve cero issues.
- `flutter test --exclude-tags golden` pasa.
- `flutter test --tags golden` pasa.
- El required check `Integration` ejecutó los escenarios en un dispositivo o
  runner controlado; la evidencia manual sola no satisface 10/10.
- `flutter build ios --no-codesign` y `flutter build apk --debug` pasan.
- Gitleaks no detecta secretos.
- No hay artefactos generados incorrectos ni cambios ajenos en ningún PR.
- La auditoría de overlap de `super-pull-request.md` devuelve cero archivos
  duplicados entre PRs.
- Ningún commit publicado deja tests o analyzer en RED.
- Ningún stack activo supera dos niveles y todos los PRs públicos reciben CI
  contra `develop`.
- Branch protection tiene los required checks reales, incluyendo Gitleaks si
  la organización lo exige.
- CODEOWNERS, aprobaciones independientes, conversaciones resueltas y
  dismiss-stale-reviews están activos.
- La política de squash/merge está unificada en comandos y GitHub.
- El PR 0 de bootstrap se fusionó primero si era necesario; luego el PR 1 de
  controles se fusionó; los PRs 2 a 6 se fusionaron
  secuencialmente a `develop`; PR 7 se fusionó como núcleo atómico; PR 8 se
  completó después.
- El release candidate tiene plan de migración/rollback de la base local.
- `main` solo recibe `release/*` o `hotfix/*`, con tag y back-merge posterior.
- `GIT_FLOW.md` está versionado en el root del repositorio canónico.
- README, AGENTS, MD, LEARN y `.ai` reflejan el estado ya fusionado.

## 15. Checklist operativo por PR

```text
[ ] La rama tiene prefijo permitido y deriva de la base correcta.
[ ] La spec y el alcance de la capacidad están identificados.
[ ] Se ejecutó el análisis de secretos.
[ ] No hay build/, .dart_tool/, Pods/, ephemeral/ ni plugin registrants.
[ ] Se usó super-commit.md y hubo confirmación explícita del plan.
[ ] Cada commit usa Conventional Commits en inglés.
[ ] Tests y código de la capacidad están juntos y la rama final compila.
[ ] No existe ningún commit publicado con analyzer/tests RED.
[ ] Generated files fueron regenerados desde sus fuentes.
[ ] flutter analyze pasa.
[ ] Tests no-golden pasan.
[ ] Goldens pasan cuando la capacidad toca UI o fixtures.
[ ] Integración fue ejecutada cuando aplica.
[ ] La auditoría de compilación justifica cualquier PR atómico grande.
[ ] El diff fue clasificado por super-pull-request.md.
[ ] La auditoría de overlap no encuentra duplicados.
[ ] El reviewer usa la matriz de arquitectura real del repositorio.
[ ] La base del PR es la rama correcta del stack.
[ ] El título del PR tiene <= 72 caracteres y no tiene numeración.
[ ] CI y required checks están verdes.
[ ] CODEOWNERS y aprobaciones independientes están satisfechos.
[ ] La revisión humana cubrió alcance, arquitectura, tests y seguridad.
[ ] El merge se ejecutará en orden y con la estrategia oficial.
[ ] El PR tiene plan de rollback si toca datos, seguridad o infraestructura.
```
