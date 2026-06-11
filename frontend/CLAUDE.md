# Flutter App (`frontend/`) — Claude Context

Arabic learning app for iOS, Android & web. Arabic-only UI (RTL).

## Directory Map

```
lib/
├── main.dart                 # bootstrap: Supabase init, localization, BLoC providers
├── app/
│   ├── app.dart              # root MaterialApp
│   ├── router.dart           # all routes — start here to find any page
│   ├── home/                 # lesson catalog (filter bar, lesson cards)
│   ├── lesson/               # story reader: tabs (story/keywords/grammar/quiz),
│   │                         #   TTS playback (controller/, utils/), unlock/paywall gate
│   ├── practice/             # flashcard training (keyword practice)
│   ├── my_library/           # favorites + learned lessons
│   ├── paywall/              # subscription purchase UI
│   ├── subscription/         # subscription state cubit (global)
│   ├── settings/             # settings, auth, about, legal, account deletion
│   ├── util/                 # small pure helpers (Arabic digits/dates, level colors)
│   └── widgets/              # app-wide shared widgets (web_frame)
├── constant/                 # colors, typography, legal links, lesson constants
└── data/
    ├── supabase_client.dart  # THE global client — never instantiate another
    ├── models/               # plain models with fromJson (no Equatable)
    ├── repositories/         # one per domain; all Supabase queries live here
    └── services/             # TTS/translation/purchases/local storage/app info
```

Each feature folder follows `cubit/` + `view/` + `widgets/` (+ `tab_views/`,
`controller/`, `utils/` in `lesson/`). Pages (`*_page.dart`) wire up
providers; views (`*_view.dart`) build UI; one widget per file in `widgets/`.

## Commands

```bash
flutter pub get
flutter analyze --fatal-infos   # CI gate — must be clean, warnings included
flutter test                    # all unit/widget tests in test/
flutter run -d chrome           # quickest manual check (web)
```

Run against local Supabase: `--dart-define=SUPABASE_URL=http://localhost:54321 --dart-define=SUPABASE_ANON_KEY=<local key>`.

## State Management (Cubit/BLoC)

- `Cubit` for simple state, `Bloc` for event-driven flows
- States extend `Equatable`, implement `copyWith`, and carry a `status` enum:
  `initial | loading | success | error`
- Cubits call repositories — never call Supabase directly from a cubit
- No business logic in widgets; `BlocBuilder` for rebuilds, `BlocListener`
  for side effects (snackbars, navigation)

```dart
class FooState extends Equatable {
  const FooState({this.status = FooStatus.initial, ...});
  final FooStatus status;

  @override
  List<Object?> get props => [status, ...];

  FooState copyWith({FooStatus? status, ...}) => FooState(status: status ?? this.status, ...);
}
```

## Data Layer

- Repository pattern: one repository per domain (e.g. `LessonRepository`)
- `.withConverter()` on Supabase queries for type-safe mapping
- Models have `factory fromJson(Map<String, dynamic>)`; models do NOT extend
  Equatable (that's for states/events only)

```dart
supabase.from('lessons').select().withConverter((data) => data.map(Lesson.fromJson).toList());
```

## Widgets & Style

- `StatelessWidget` by default; `const` constructors and `final` fields everywhere possible
- One widget per file in the feature's `widgets/` folder; keep view files as
  thin composition — extract anything substantial into a named widget file
- `easy_localization` for every user-facing string — no hardcoded strings;
  keys live in `assets/translations/ar.json`

## Error Handling

- Cubits catch exceptions and emit error state — never swallow silently
- UI shows snackbars/dialogs via `BlocListener` on error status

## Quality Gate

`flutter analyze --fatal-infos` (Very Good Analysis) and `flutter test` must
both pass before committing — fix all warnings/infos, not just errors.

## Platform Notes

- Web build has billing disabled (`purchases_flutter` has no web impl)
- Tests live flat in `test/`, named `<subject>_test.dart`
