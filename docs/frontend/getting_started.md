# Frontend Development Guide

## Prerequisites

*   Flutter SDK compatible with version `3.35.2`
*   Supabase project credentials

## Setup

1.  **Environment Variables**:
    Create a `.env` file in `frontend/` with your Supabase keys:
    ```env
    SUPABASE_URL=https://your-project.supabase.co
    SUPABASE_ANON_KEY=your-anon-key
    ```

2.  **Dependencies**:
    ```bash
    cd frontend
    flutter pub get
    ```

3.  **Run**:
    ```bash
    flutter run
    ```

## Common Tasks

### Adding a New dependency
Add it to `pubspec.yaml` and run `flutter pub get`.

### Running Tests
```bash
flutter test
```

### Analyzing Code
```bash
flutter analyze
```
