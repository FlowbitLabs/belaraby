import { describe, expect, it } from "vitest";
import { compoundPrimaryKeys } from "./primaryKeys";

// Guards the contract between ra-supabase and the schema: a missing or
// wrong entry breaks every read on that resource (the data provider would
// look for a non-existent `id` column). App.tsx wires this map into
// supabaseDataProvider verbatim.
describe("compoundPrimaryKeys", () => {
  it("maps user_favorites to (user_id, lesson_id)", () => {
    expect(compoundPrimaryKeys.get("user_favorites")).toEqual([
      "user_id",
      "lesson_id",
    ]);
  });

  it("maps user_learned_lessons to (user_id, lesson_id)", () => {
    expect(compoundPrimaryKeys.get("user_learned_lessons")).toEqual([
      "user_id",
      "lesson_id",
    ]);
  });

  it("leaves id-keyed tables to the data provider default", () => {
    for (const resource of [
      "lessons",
      "lesson_exercises",
      "lesson_exercise_options",
      "lesson_grammar",
      "lesson_keywords",
      "profiles",
      "subscriptions",
    ]) {
      expect(compoundPrimaryKeys.has(resource)).toBe(false);
    }
  });
});
