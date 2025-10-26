-- Migration: add_test_users_table
-- Creates a table for test users (for dev/testing)

CREATE TABLE public.test_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  full_name text,
  created_at timestamptz DEFAULT now()
);