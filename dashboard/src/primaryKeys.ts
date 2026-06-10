/**
 * Tables whose primary key is compound instead of a single `id` column.
 *
 * ra-supabase needs this map to synthesize a record `id` (it joins the key
 * columns) and to target the right rows on getOne/update/delete. If a table
 * is missing here, the data provider assumes an `id` column exists and every
 * read for that resource breaks.
 *
 * Keep in sync with the table definitions in supabase/migrations/ — both
 * tables below use PRIMARY KEY (user_id, lesson_id).
 */
export const compoundPrimaryKeys = new Map<string, string[]>([
  ["user_favorites", ["user_id", "lesson_id"]],
  ["user_learned_lessons", ["user_id", "lesson_id"]],
]);
