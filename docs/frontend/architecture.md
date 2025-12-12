# Frontend Architecture

The Belaraby frontend is built with Flutter, prioritizing simplicity, maintainability, and ease of development. We avoid complex architectural patterns (like clean architecture with multiple layers of abstraction) in favor of a pragmatic, straightforward approach.

## Folder Structure

The project structure is flat and functional:

```
frontend/lib/
├── app/                 # Main application features
│   ├── home/            # Home screen and widgets
│   ├── lesson/          # Lesson player and logic
│   ├── my_library/      # User's library
│   ├── router.dart      # Simple navigation configuration
│   └── app.dart         # App entry point configuration
├── data/                # Data layer
│   ├── models/          # Data models (JSON handling)
│   └── repositories/    # Data access (Supabase calls)
├── constant/            # App-wide constants (colors, typography)
└── main.dart            # Entry point
```

## Key Principles

1.  **Keep it Simple**: No unnecessary abstractions.
2.  **Feature-Based Organization**: Group code by feature (home, lesson, library) rather than by type (screens, controllers).
3.  **Direct Data Access**: Repositories handle data fetching directly from Supabase.
4.  **State Management**: `flutter_bloc` is used for state management in a simple way (Cubits).
