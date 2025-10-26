create table public.subscriptions (
  id uuid not null default gen_random_uuid(),
  user_id uuid references auth.users(id),
  status text not null check (
    status = any (array['active', 'canceled', 'trial', 'past_due'])
  ),
  price_id text,
  started_at timestamp without time zone default now(),
  current_period_end timestamp without time zone,
  cancel_at_period_end boolean default false,
  constraint subscriptions_pkey primary key (id)
);
