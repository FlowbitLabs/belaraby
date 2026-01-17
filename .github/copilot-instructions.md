# Copilot Instructions

You are an expert software engineer specializing in **Flutter (Dart)** and **React (TypeScript)** development. You are working on "Belaraby", a project that consists of a Flutter mobile app (`frontend/`) and a React-based admin dashboard (`dashboard/`), both powered by **Supabase**.

## Project Structure

-   `frontend/`: **Flutter** application for Android/iOS.
-   `dashboard/`: **Vite + React + TypeScript** admin dashboard using **React-Admin**.
-   `supabase/`: Supabase configuration, migrations, and seed data.
-   `docs/`: Documentation (MkDocs).

---

## 📱 Flutter Development (`frontend/`)

-   **State Management**: STRICTLY use **Bloc** (`flutter_bloc`) pattern.
    -   Define `Events` and `States` clearly.
    -   Extend `Equatable` for all Events and States to ensure proper comparison.
    -   Keep UI execution logic inside Blocs, not in the UI widgets.
-   **Linting & Style**:
    -   Adhere to **Very Good Analysis** strictly.
    -   ALWAYS use `const` constructors for widgets and classes where immutable.
    -   Prefer `final` variables.
-   **UI & Widgets**:
    -   Break down large widgets into smaller, reusable widgets.
    -   Use `StatelessWidget` when internal state is not required (rely on Bloc for state).
-   **Localization**:
    -   Use `easy_localization` for all user-facing strings.
    -   Do not hardcode strings in the UI. Reference keys from `assets/translations/`.
-   **Data Layer**:
    -   Use `supabase_flutter` for backend interactions.
    -   Implement repository pattern to separate data fetching from business logic (Blocs).

## 💻 Dashboard Development (`dashboard/`)

-   **Framework**: React 19 with Vite and TypeScript.
-   **Library**: **React-Admin** (`react-admin`).
    -   Prioritize using usage of `<Resource>`, `<List>`, `<Edit>`, `<Create>`, and `<SimpleForm>` from react-admin over custom implementation when possible.
    -   Use `ra-supabase` data provider.
-   **UI Components**:
    -   Use **Material UI (MUI)** (`@mui/material`) for custom components to match the React-Admin theme.
-   **Code Style**:
    -   Functional components with Hooks.
    -   **Strict TypeScript**: Define interfaces for props and state. Avoid `any`.
    -   Use named exports for components.

## 🗄️ Supabase & Database

-   **SQL**: Write idempotent migrations in `supabase/migrations`.
-   **Row Level Security (RLS)**: Always enable RLS on tables and define policies for SELECT, INSERT, UPDATE, DELETE.
-   **Types**: Ensure frontend and dashboard types match the database schema.

## General Coding Principles

-   **Conciseness**: Write simple, readable, and maintainable code.
-   **Dependencies**: Check `pubspec.yaml` and `package.json` before suggesting new libraries. Prefer existing dependencies.
-   **Error Handling**: specific styling.
    -   Flutter: Use `BlocListener` for showing Snackbars/Dialogs on errors.
    -   React: Use `useNotify` from react-admin for notifications.
