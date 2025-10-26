create table public.user_learned_lessons (
  user_id uuid not null references auth.users(id),
  lesson_id uuid not null references public.lessons(id),
  learned_at timestamp without time zone default now(),
  constraint user_learned_lessons_pkey primary key (user_id, lesson_id)
);
