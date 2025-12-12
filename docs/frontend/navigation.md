# Navigation

Navigation in Belaraby is handled by a simple, standard Flutter `Navigator` combined with a bottom navigation bar. We moved away from complex routing packages like `go_router` to reduce maintenance overhead.

## Router Configuration

The core navigation logic is in `frontend/lib/app/router.dart`.

### Main Screen with Bottom Nav

The `MainScreen` widget uses an `IndexedStack` to preserve the state of the main tabs:
*   Home
*   Training (Coming Soon)
*   My Library

This ensures that switching tabs is instant and doesn't lose your place.

### Navigation Helper

We use simple helper functions for navigating to specific pages, keeping the code clean and type-safe.

```dart
// Example: Navigate to a lesson
void navigateToLesson(BuildContext context, Lesson lesson) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LessonPage(lesson),
    ),
  );
}
```

## Usage

To navigate to a new screen (e.g., from a list item):

```dart
// Import the router
import 'package:belaraby/app/router.dart';

// Call the helper function
onTap: () {
  navigateToLesson(context, myLesson);
}
```

To go back:

```dart
Navigator.of(context).pop();
```
