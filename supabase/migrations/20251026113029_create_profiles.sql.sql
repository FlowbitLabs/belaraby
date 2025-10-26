create table public.profiles (
  id uuid not null,
  username text unique,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone default now(),
  role text default 'student' check (
    role = any (array['student', 'teacher', 'admin'])
  ),
  constraint profiles_pkey primary key (id),
  constraint profiles_id_fkey foreign key (id) references auth.users(id)
);
