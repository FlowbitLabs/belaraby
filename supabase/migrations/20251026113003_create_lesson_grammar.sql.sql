create table public.lesson_grammar (
  id uuid not null default gen_random_uuid(),
  lesson_id uuid references public.lessons(id),
  explanation text not null,
  constraint lesson_grammar_pkey primary key (id)
);
