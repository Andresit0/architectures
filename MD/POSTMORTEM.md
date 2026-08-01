# POSTMORTEM — Builds enmascarados y dependencias sin mantenimiento

**Fecha**: 2026-08-01
**Severidad**: Media (no hubo pérdida de datos ni release roto, pero el pipeline podía dar falsa confianza)
**Estado**: Mitigado con la serie de PRs P0–P8 (#13–#35)

---

## Resumen del incidente

El pipeline CI daba **falsa sensación de seguridad**: los builds dependían del job `Test`
(`needs: [test]`), de modo que si un test estaba rojo, los builds ni siquiera se ejecutaban.
En paralelo, el paquete `flutter_jailbreak_detection` estaba **sin mantenimiento** (AGP 7,
sin `namespace`, Kotlin antiguo) y solo compilaba gracias a un hack de reflexión en
`android/build.gradle.kts` que se rompía silenciosamente con AGP 8+.

La combinación hacía que una regresión de build de Android pudiera quedar **oculta por un
test rojo** — el incidente raíz que esta serie de PRs previene estructuralmente.

## Causa raíz

1. **Builds dependientes de tests** (`needs: [analyze, test]`): un build roto no se detectaba
   si los tests fallaban primero. El build no era una validación independiente.
2. **Dependencia sin mantenimiento**: `flutter_jailbreak_detection` no se mantenía para AGP 8+
   y dependía de un hack local frágil.
3. **Sin auditoría de dependencias**: no existía política de verificación de mantenimiento
   de paquetes antes de adoptarlos.
4. **Sin gate estructural**: no había ninguna prueba que impidiera reintroducir la regresión
   (ej.: volver a hacer builds dependientes de test, o mover jobs a macOS innecesariamente).

## Acciones tomadas

| Acción | PR(s) |
|--------|-------|
| Desacoplar builds de tests (`needs: [analyze]`) | #17 |
| Migrar a `flutter_jailbreak_detection_plus` (fork mantenido) | #24 |
| Gate anti-masking en código (`workflow_gates_test.dart`) | #29 |
| Goldens cross-platform en Linux (determinismo + tolerancia) | #28 |
| Cache de runners (flutter-action + CocoaPods) | #30 |
| Dependabot grouped + auto-merge patch/minor | #31 |
| Merge strategy: auto-merge + squash + delete branch (fallback merge queue) | #26, #27 |
| Docs sincronizadas (README/LEARN) | #33, #35 |

## Prevención (P0–P8)

- **Gate anti-masking** (`test/architecture/workflow_gates_test.dart`, corre en job `Test`,
  sin tag `golden`) bloquea el merge si el workflow regresa a:
  - Builds que dependen de `Test`.
  - `Analyze`/`Test`/`Test Goldens` fuera de Linux.
  - Goldens sin `@Tags(['golden'])`.
  - Más de 2 jobs en macOS.
- **Builds desacoplados** garantizan que una regresión de compilación nunca quede enmascarada.
- **Política de plugins** (ver `MD/APP_PACKAGE_WRAPPER.md`): verificar mantenimiento antes de
  adoptar; preferir fork mantenido si el paquete original no evoluciona.
- **Merge strategy**: squash + auto-merge + delete-branch; historial limpio y CI como única
  puerta (junto con los 6 gates del reviewer).

## Trazabilidad de PRs

| PR | Área | Descripción |
|----|------|-------------|
| #13 | Android | Inyecta `namespace` para plugins legacy |
| #14 | CI | Habilita dependabot (pub + github-actions) |
| #15 | CI | Bump `actions/checkout` 5→7 |
| #16 | CI | Bump `codecov/codecov-action` 5→7 |
| #17 | CI | Optimiza costos (Linux) y desacopla builds de tests |
| #18 | deps | Bump `internet_connection_checker_plus` |
| #19 | deps | Bump `path_provider` |
| #20 | deps | Bump `dio` |
| #21 | deps | Bump `riverpod_annotation` |
| #22 | deps | Bump `riverpod_lint` |
| #23 | CI | Smoke check APK en Gate 5 del reviewer |
| #24 | deps | Migra a `flutter_jailbreak_detection_plus` |
| #25 | docs | Documenta CI/CD en LEARN.md |
| #26 | repo | Gitignore registrants desktop |
| #27 | CI | Probe del fallback merge strategy |
| #28 | tests | Goldens cross-platform (golden_toolkit → Linux) |
| #29 | tests | Gate anti-masking |
| #30 | CI | Cache de runners |
| #31 | CI | Dependabot grouped + auto-merge |
| #33 | docs | README: tests cross-platform |
| #35 | docs | LEARN: sección CI/CD actualizada |

## Desviaciones corporativas (decisiones conscientes)

- **`required_pull_request_reviews: null`**: repo de cuenta única; los PRs pasan por los 6
  gates del `super-pull-request-reviewer` (incluido smoke check de build) en lugar de una
  aprobación humana. En una empresa grande esto no sería aceptable — siempre habría ≥1
  aprobación humana.
- **Gate anti-masking como test Dart**: las empresas grandes lo enforcean con CODEOWNERS /
  políticas de enterprise. Aquí un test en `test/` es el mecanismo práctico para una cuenta
  individual.
- **Merge queue no disponible** en cuentas personales (feature de organizaciones) → fallback
  documentado: auto-merge + squash + delete branch.

## Lecciones

1. Los builds deben validarse de forma **independiente** de los tests. Nunca `needs: [test]`.
2. Toda dependencia externa debe auditarse por mantenimiento; si no evoluciona, se adopta un
   fork mantenido (o se evalúa reemplazo).
3. Las mejoras de CI/seguridad que se hicieron una vez deben quedar **bloqueadas
   estructuralmente** para que no se reintroduzcan por accidente.
4. Documentar el estado real después de cada serie de cambios evita que la documentación
   mienta sobre lo que CI realmente hace.
