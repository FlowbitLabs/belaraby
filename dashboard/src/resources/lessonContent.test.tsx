// Render smoke tests for the lesson-content authoring resources. These
// views are reached from the lesson edit tabs (no list), so nothing else
// exercises them in CI — a broken import or form wiring would otherwise
// only surface in production.

import type { ReactElement } from "react";
import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { Route, Routes } from "react-router-dom";
import {
  AdminContext,
  ResourceContextProvider,
  TestMemoryRouter,
  defaultI18nProvider,
  testDataProvider,
} from "react-admin";
import type { DataProvider } from "react-admin";
import { LessonExerciseCreate, LessonExerciseEdit } from "./lessonExercises";
import { LessonExerciseOptionCreate } from "./lessonExerciseOptions";
import { LessonGrammarCreate } from "./lessonGrammar";
import { LessonKeywordCreate } from "./lessonKeywords";

const renderCreate = (resource: string, view: ReactElement) =>
  render(
    <TestMemoryRouter>
      <AdminContext
        dataProvider={testDataProvider()}
        i18nProvider={defaultI18nProvider}
      >
        <ResourceContextProvider value={resource}>
          {view}
        </ResourceContextProvider>
      </AdminContext>
    </TestMemoryRouter>,
  );

describe("lesson content create views", () => {
  it("lesson_exercises renders the question input", () => {
    renderCreate("lesson_exercises", <LessonExerciseCreate />);
    expect(screen.getByLabelText(/question/i)).toBeInTheDocument();
  });

  it("lesson_exercise_options renders the option text and correct flag", () => {
    renderCreate("lesson_exercise_options", <LessonExerciseOptionCreate />);
    expect(screen.getByLabelText(/option/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/correct answer/i)).toBeInTheDocument();
  });

  it("lesson_grammar renders the explanation input", () => {
    renderCreate("lesson_grammar", <LessonGrammarCreate />);
    expect(screen.getByLabelText(/explanation/i)).toBeInTheDocument();
  });

  it("lesson_keywords renders the keyword input", () => {
    renderCreate("lesson_keywords", <LessonKeywordCreate />);
    expect(screen.getByLabelText(/keyword/i)).toBeInTheDocument();
  });
});

describe("LessonExerciseEdit", () => {
  it("loads the exercise and shows its options panel", async () => {
    // Concrete fixtures cannot satisfy the data provider's generic method
    // signatures, hence the unknown-casts.
    const dataProvider = testDataProvider({
      getOne: (async () => ({
        data: { id: "ex-1", lesson_id: "lesson-1", question: "اختر الإجابة" },
      })) as unknown as DataProvider["getOne"],
      getManyReference: (async () => ({
        data: [
          {
            id: "opt-1",
            exercise_id: "ex-1",
            option_text: "نعم",
            is_correct: true,
          },
        ],
        total: 1,
      })) as unknown as DataProvider["getManyReference"],
    });
    render(
      <TestMemoryRouter initialEntries={["/lesson_exercises/ex-1"]}>
        <AdminContext
          dataProvider={dataProvider}
          i18nProvider={defaultI18nProvider}
        >
          <ResourceContextProvider value="lesson_exercises">
            <Routes>
              <Route
                path="/lesson_exercises/:id"
                element={<LessonExerciseEdit />}
              />
            </Routes>
          </ResourceContextProvider>
        </AdminContext>
      </TestMemoryRouter>,
    );
    expect(await screen.findByDisplayValue("اختر الإجابة")).toBeInTheDocument();
    expect(await screen.findByText("نعم")).toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: /add option/i }),
    ).toBeInTheDocument();
  });
});
