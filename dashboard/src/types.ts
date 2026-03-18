export type LessonLevel = "A1" | "A2" | "B1" | "B2" | "C1" | "C2";

export type SubscriptionStatus =
  | "active"
  | "trialing"
  | "past_due"
  | "canceled"
  | "incomplete";

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

export interface Profile {
  id: string;
  username: string;
  full_name: string;
  avatar_url: string | null;
  role: UserRole;
  created_at: string;
}

export interface Subscription {
  id: string;
  user_id: string;
  status: SubscriptionStatus;
  price_id: string;
  started_at: string;
  current_period_end: string;
  cancel_at_period_end: boolean;
}
