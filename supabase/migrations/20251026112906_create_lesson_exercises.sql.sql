create table public.lesson_exercises (
  id uuid not null default gen_random_uuid(),
  lesson_id uuid references public.lessons(id),
  question text not null,
  constraint lesson_exercises_pkey primary key (id)
);