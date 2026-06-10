import type { ReactNode } from "react";
import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import {
  AdminContext,
  Form,
  RecordContextProvider,
  ResourceContextProvider,
  TestMemoryRouter,
  defaultI18nProvider,
  testDataProvider,
} from "react-admin";
import {
  AddChildRecordButton,
  ChildEditToolbar,
  profileDisplayName,
  redirectToExerciseEdit,
  redirectToLessonEdit,
} from "./shared";

const renderWithAdmin = (ui: ReactNode) =>
  render(
    <TestMemoryRouter>
      <AdminContext
        dataProvider={testDataProvider()}
        i18nProvider={defaultI18nProvider}
      >
        {ui}
      </AdminContext>
    </TestMemoryRouter>,
  );

describe("redirectToLessonEdit", () => {
  it("returns to the parent lesson edit view after a child save", () => {
    expect(
      redirectToLessonEdit("lesson_exercises", "ex-1", {
        id: "ex-1",
        lesson_id: "lesson-1",
      }),
    ).toBe("/lessons/lesson-1");
  });

  it("falls back to the lessons list when the parent id is unknown", () => {
    expect(redirectToLessonEdit()).toBe("/lessons");
  });
});

describe("redirectToExerciseEdit", () => {
  it("returns to the parent exercise edit view after an option save", () => {
    expect(
      redirectToExerciseEdit("lesson_exercise_options", "opt-1", {
        id: "opt-1",
        exercise_id: "ex-1",
      }),
    ).toBe("/lesson_exercises/ex-1");
  });

  it("falls back to the lessons list when the parent id is unknown", () => {
    expect(redirectToExerciseEdit()).toBe("/lessons");
  });
});

describe("profileDisplayName", () => {
  it("prefers the username", () => {
    expect(profileDisplayName({ id: "u-1", username: "fatima" })).toBe(
      "fatima",
    );
  });

  it("falls back to the id for anonymous sign-ups", () => {
    expect(profileDisplayName({ id: "u-1", username: null })).toBe("u-1");
  });
});

describe("AddChildRecordButton", () => {
  it("links to the child create page with the parent FK prefilled", () => {
    renderWithAdmin(
      <ResourceContextProvider value="lessons">
        <RecordContextProvider value={{ id: "lesson-1" }}>
          <AddChildRecordButton
            resource="lesson_exercises"
            parentField="lesson_id"
            label="Add exercise"
          />
        </RecordContextProvider>
      </ResourceContextProvider>,
    );
    const link = screen.getByRole("link", { name: /add exercise/i });
    const expectedSource = encodeURIComponent(
      JSON.stringify({ lesson_id: "lesson-1" }),
    );
    expect(link).toHaveAttribute(
      "href",
      `/lesson_exercises/create?source=${expectedSource}`,
    );
  });

  it("renders nothing until the parent record is loaded", () => {
    renderWithAdmin(
      <ResourceContextProvider value="lessons">
        <AddChildRecordButton
          resource="lesson_exercises"
          parentField="lesson_id"
          label="Add exercise"
        />
      </ResourceContextProvider>,
    );
    expect(screen.queryByRole("link")).not.toBeInTheDocument();
  });
});

describe("ChildEditToolbar", () => {
  it("renders save and a pessimistic delete", () => {
    renderWithAdmin(
      <ResourceContextProvider value="lesson_exercises">
        <RecordContextProvider value={{ id: "ex-1", lesson_id: "lesson-1" }}>
          <Form onSubmit={() => undefined}>
            <ChildEditToolbar
              parentField="lesson_id"
              parentResource="lessons"
            />
          </Form>
        </RecordContextProvider>
      </ResourceContextProvider>,
    );
    expect(screen.getByRole("button", { name: /save/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /delete/i })).toBeInTheDocument();
  });
});
