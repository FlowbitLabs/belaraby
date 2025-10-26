create table public.user_favorites (
  user_id uuid not null references auth.users(id),
  lesson_id uuid not null references public.lessons(id),
  constraint user_favorites_pkey primary key (user_id, lesson_id)
);
