export type LessonLevel = "A1" | "A2" | "B1" | "B2" | "C1" | "C2";

export type UserRole = "student" | "teacher" | "admin";

export interface Lesson {
  id: string;
  title: string;
  body: string;
  hero_image: string;
  level: LessonLevel;
  grade: string;
  paid: boolean;
  date: string | null;
  created_at: string;
}

export interface LessonExercise {
  id: string;
  lesson_id: string;
  question: string;
}

export interface LessonExerciseOption {
  id: string;
  exercise_id: string;
  option_text: string;
  is_correct: boolean;
}

export interface LessonGrammar {
  id: string;
  lesson_id: string;
  title: string;
  explanation: string;
  example: string | null;
}

export interface LessonKeyword {
  id: string;
  lesson_id: string;
  keyword: string;
  meaning: string;
}

/**
 * Anonymous sign-ups get a profile row via the auth.users trigger that only
 * sets `id` — username and full_name are NULL until the user fills them in.
 */
export interface Profile {
  id: string;
  username: string | null;
  full_name: string | null;
  avatar_url: string | null;
  role: UserRole;
  is_admin: boolean;
  created_at: string;
}

/**
 * Mirrors public.subscriptions. Rows are written exclusively by the
 * `revenuecat-webhook` edge function — the dashboard reads them only.
 * Premium access is gated solely by `expires_at` (see
 * public.has_active_subscription()); `status` and `will_renew` are
 * informational.
 */
export interface Subscription {
  id: string;
  user_id: string;
  entitlement_id: string;
  product_id: string | null;
  store: string | null;
  environment: string | null;
  status: string;
  will_renew: boolean;
  original_transaction_id: string | null;
  expires_at: string | null;
  created_at: string;
  updated_at: string;
}

/**
 * Compound primary key (user_id, lesson_id) — `id` is synthesized by
 * ra-supabase (see the primaryKeys map in App.tsx).
 */
export interface UserFavorite {
  id: string;
  user_id: string;
  lesson_id: string;
  created_at: string;
}

/**
 * Compound primary key (user_id, lesson_id) — `id` is synthesized by
 * ra-supabase (see the primaryKeys map in App.tsx).
 */
export interface UserLearnedLesson {
  id: string;
  user_id: string;
  lesson_id: string;
  learned_at: string;
}
