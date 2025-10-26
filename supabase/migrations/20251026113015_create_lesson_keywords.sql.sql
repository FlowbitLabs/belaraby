create table public.lesson_keywords (
  id uuid not null default gen_random_uuid(),
  lesson_id uuid references public.lessons(id),
  keyword text not null,
  constraint lesson_keywords_pkey primary key (id)
);
