-- Adds structured fields to lesson_grammar so a grammar note renders as a
-- titled card with an optional example sentence in the app:
--   title       — short heading of the rule (required going forward; existing
--                 rows get '' so the column can be NOT NULL)
--   example     — optional example sentence illustrating the rule
-- Rollback:
--   alter table public.lesson_grammar drop column if exists title;
--   alter table public.lesson_grammar drop column if exists example;
alter table public.lesson_grammar
  add column if not exists title text not null default '',
  add column if not exists example text;
