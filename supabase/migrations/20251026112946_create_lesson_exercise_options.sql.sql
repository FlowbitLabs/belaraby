create table public.lesson_exercise_options (
  id uuid not null default gen_random_uuid(),
  exercise_id uuid references public.lesson_exercises(id),
  option_text text not null,
  is_correct boolean default false,
  constraint lesson_exercise_options_pkey primary key (id)
);
