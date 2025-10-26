create table public.lessons (
  id uuid not null default gen_random_uuid(),
  title text not null,
  body text not null,
  hero_image text,
  level text not null check (
    level = any (array['A1', 'A2', 'B1', 'B2', 'C1', 'C2'])
  ),
  created_at timestamp without time zone default now(),
  grade text,
  paid boolean not null default false,
  date date,
  constraint lessons_pkey primary key (id)
);
