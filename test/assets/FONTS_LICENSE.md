# Font licenses

The test fixtures in this directory are used by golden tests to render
deterministically across platforms (Linux CI, macOS local). They are **not**
shipped with the application.

| File | Source | License |
|------|--------|---------|
| `MaterialIcons-Regular.otf` | Flutter SDK `bin/cache/artifacts/material_fonts/` | Material Icons font — **CC-BY-4.0** (Attribution 4.0 International) |
| `Roboto-Regular.ttf` | Flutter SDK `bin/cache/artifacts/material_fonts/` | Roboto font — **Apache License 2.0** |
| `Roboto-Medium.ttf` | Flutter SDK `bin/cache/artifacts/material_fonts/` | Roboto font — **Apache License 2.0** |
| `Roboto-Bold.ttf` | Flutter SDK `bin/cache/artifacts/material_fonts/` | Roboto font — **Apache License 2.0** |

## Material Icons — CC-BY-4.0

The Material Icons font is licensed under the Creative Commons
Attribution 4.0 International License (CC-BY-4.0).

- License: https://creativecommons.org/licenses/by/4.0/
- Attribution: "Material Icons" (c) Google LLC.
- Full license text: `MaterialIcons_LICENSE.txt` in the Flutter SDK
  (`bin/cache/artifacts/material_fonts/`).

## Roboto — Apache License 2.0

Roboto is licensed under the Apache License, Version 2.0.

- License: https://www.apache.org/licenses/LICENSE-2.0
- Copyright: Roboto (c) Google LLC.
- Full license text: `Roboto_LICENSE.txt` in the Flutter SDK
  (`bin/cache/artifacts/material_fonts/`).

All Roboto weights loaded for golden tests (`Regular`, `Medium`, `Bold`)
come from the same SDK artifact directory and share the same license.
