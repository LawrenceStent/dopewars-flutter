# Dopewars — Flutter Edition

A modern remake of the classic **dopewars** trading game, playable in the browser.

You have 31 days to turn $2,000 in cash and $5,500 of loan-shark debt into a
fortune, by buying low and selling high across New York City — while dodging
the cops, random muggings, and an interest rate that never sleeps.

## Play

**[Play in your browser →](https://dopewars-flutter.web.app)**

## Features

- Full drug market with location-based supply and demand, plus special deals
- Combat with cops and dealers, guns, and hired muscle
- Bank and loan shark with compounding interest
- NPC network: build relationships with suppliers and buyers for better pricing
- Contracts, scenarios, and random events
- Local high scores and save/load

## Development

Requires the Flutter SDK (built against 3.32.x).

```bash
flutter pub get
flutter test          # 30 test files across domain, cubits, and integration
flutter run -d chrome # local dev
```

Build for web:

```bash
flutter build web --release
```

## Architecture

Clean Architecture across three layers:

- `lib/domain/` — entities, value objects, and pure game-rule services
- `lib/application/` — use cases orchestrating domain logic
- `lib/presentation/` — pages, widgets, and `flutter_bloc` cubits

State is managed with cubits (`GameCubit`, `TradingCubit`, `CombatCubit`,
`NpcNetworkCubit`), wired via GetIt in `lib/injection_container.dart`.
Money is represented in cents to avoid floating-point drift; see
`lib/core/value_objects/`.

Design notes and specs live in `docs/`.

## Licence and attribution

This game is a derivative work of [dopewars](https://dopewars.sourceforge.io/)
by **Ben Webb**, and reuses its game data and balance constants. dopewars is
free software licensed under the GNU General Public License.

Accordingly, this project is distributed under the **GNU GPL v2 or later**.
See [LICENSE](LICENSE) for the full text.

What this means in practice:

- You may use, modify, sell, and redistribute this game freely.
- Any distributed build — including the web build, which ships compiled Dart
  to the browser — must be accompanied by an offer of the corresponding
  source. The in-app footer and this repository serve that purpose; keep the
  URL in `lib/core/constants/app_info.dart` pointing at a public repository.
- Derivative works must also be GPL-licensed.

Note that the GPL is incompatible with the Apple App Store's terms of
distribution, so iOS release is not available for this codebase as licensed.
