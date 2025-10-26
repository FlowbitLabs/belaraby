-- To apply this locally, run:
-- psql <Database URL> -f supabase/seed.local.sql
-- To locate the local Database URL; run `supabase status`
-- To run supabase locally, run `supabase start`
-- =========================================================
-- 🧩 Supabase Seed Data (Arabic Production-like Sample)
-- =========================================================

-- ✅ Profiles (use your real auth.users UUIDs here)
insert into public.profiles (id, username, full_name, role)
values
  ('c4f7a1f5-aaaa-bbbb-cccc-123456789abc', 'teacher1', 'الأستاذ أحمد', 'teacher'),
  ('f29b3dd4-aaaa-bbbb-cccc-987654321def', 'student1', 'الطالبة ليلى', 'student');

-- =========================================================
-- 🏫 Lessons
-- =========================================================
insert into public.lessons (title, body, level, grade, paid, hero_image, date)
values
  ('مقدمة في النحو العربي', 'تعلم أساسيات النحو بطريقة مبسطة ومفهومة مع أمثلة وتمارين.', 'A1', 'الصف الأول', false, 'https://example.com/images/grammar_intro.png', '2024-02-10'),
  ('الكلمات الأساسية في الحياة اليومية', 'تعرف على كلمات تُستخدم في مواقف الحياة اليومية مثل التسوق والمواصلات.', 'A1', 'الصف الأول', false, 'https://example.com/images/daily_vocab.png', '2024-03-15'),
  ('الضمائر في اللغة العربية', 'شرح شامل لاستخدام الضمائر في الجمل المختلفة.', 'A2', 'الصف الثاني', false, 'https://example.com/images/pronouns.png', '2024-04-05'),
  ('أزمنة الأفعال في اللغة العربية', 'تعلم الفرق بين الماضي والمضارع والمستقبل مع أمثلة وتمارين.', 'B1', 'الصف الثالث', true, 'https://example.com/images/verbs_tense.png', '2024-05-12'),
  ('الجمل المركبة وأدوات الربط', 'تعلم كيفية ربط الجمل باستخدام أدوات الربط مثل لأنّ، ولكن، حيث.', 'B2', 'الصف الرابع', true, 'https://example.com/images/compound_sentences.png', '2024-06-01');

-- =========================================================
-- 📘 Grammar (درس القواعد)
-- =========================================================
insert into public.lesson_grammar (lesson_id, explanation)
select id, 'الجملة في اللغة العربية تتكون من كلمتين أو أكثر وتعبّر عن معنى تام.'
from public.lessons
where title = 'مقدمة في النحو العربي';

insert into public.lesson_grammar (lesson_id, explanation)
select id, 'الضمائر تُستخدم بدل الأسماء لتجنب التكرار مثل: هو، هي، نحن.'
from public.lessons
where title = 'الضمائر في اللغة العربية';

insert into public.lesson_grammar (lesson_id, explanation)
select id, 'أزمنة الأفعال في اللغة العربية ثلاثة: الماضي، المضارع، المستقبل.'
from public.lessons
where title = 'أزمنة الأفعال في اللغة العربية';

insert into public.lesson_grammar (lesson_id, explanation)
select id, 'تُستخدم أدوات الربط لربط الجمل مثل: لأنّ، ولكن، حيث، ثمّ.'
from public.lessons
where title = 'الجمل المركبة وأدوات الربط';

-- =========================================================
-- 🏷️ Keywords
-- =========================================================
insert into public.lesson_keywords (lesson_id, keyword)
select id, unnest(array['جملة', 'فعل', 'فاعل'])
from public.lessons
where title = 'مقدمة في النحو العربي';

insert into public.lesson_keywords (lesson_id, keyword)
select id, unnest(array['كلمة', 'تسوق', 'حديث'])
from public.lessons
where title = 'الكلمات الأساسية في الحياة اليومية';

insert into public.lesson_keywords (lesson_id, keyword)
select id, unnest(array['هو', 'هي', 'نحن'])
from public.lessons
where title = 'الضمائر في اللغة العربية';

insert into public.lesson_keywords (lesson_id, keyword)
select id, unnest(array['ماضي', 'مضارع', 'مستقبل'])
from public.lessons
where title = 'أزمنة الأفعال في اللغة العربية';

insert into public.lesson_keywords (lesson_id, keyword)
select id, unnest(array['لأنّ', 'لكن', 'ثم'])
from public.lessons
where title = 'الجمل المركبة وأدوات الربط';

-- =========================================================
-- 🧩 Exercises
-- =========================================================
insert into public.lesson_exercises (lesson_id, question)
select id, 'اختر الجملة الصحيحة التي تحتوي على فعل.'
from public.lessons
where title = 'مقدمة في النحو العربي';

insert into public.lesson_exercises (lesson_id, question)
select id, 'اختر الكلمة الصحيحة لإكمال الجملة: "أنا ___ إلى المدرسة."'
from public.lessons
where title = 'الكلمات الأساسية في الحياة اليومية';

insert into public.lesson_exercises (lesson_id, question)
select id, 'أي من الضمائر التالية تُستخدم للمتحدث؟'
from public.lessons
where title = 'الضمائر في اللغة العربية';

insert into public.lesson_exercises (lesson_id, question)
select id, 'اختر الجملة التي تعبّر عن زمن الماضي.'
from public.lessons
where title = 'أزمنة الأفعال في اللغة العربية';

insert into public.lesson_exercises (lesson_id, question)
select id, 'اختر الأداة المناسبة لربط الجملتين: "درستُ جيداً ___ نجحتُ في الامتحان."'
from public.lessons
where title = 'الجمل المركبة وأدوات الربط';

-- =========================================================
-- 📝 Exercise Options
-- =========================================================
-- Grammar basics
insert into public.lesson_exercise_options (exercise_id, option_text, is_correct)
select e.id, o.option_text, o.is_correct
from public.lesson_exercises e
join (values
  ('الولد يكتب الدرس.', true),
  ('الولد في الفصل.', false),
  ('القلم على الطاولة.', false)
) as o(option_text, is_correct)
on true
where e.question like 'اختر الجملة الصحيحة%';

-- Daily vocabulary
insert into public.lesson_exercise_options (exercise_id, option_text, is_correct)
select e.id, o.option_text, o.is_correct
from public.lesson_exercises e
join (values
  ('أذهب', true),
  ('يأكل', false),
  ('يجلس', false)
) as o(option_text, is_correct)
on true
where e.question like 'اختر الكلمة الصحيحة%';

-- Pronouns
insert into public.lesson_exercise_options (exercise_id, option_text, is_correct)
select e.id, o.option_text, o.is_correct
from public.lesson_exercises e
join (values
  ('أنا', true),
  ('هو', false),
  ('هي', false)
) as o(option_text, is_correct)
on true
where e.question like 'أي من الضمائر%';

-- Verb tenses
insert into public.lesson_exercise_options (exercise_id, option_text, is_correct)
select e.id, o.option_text, o.is_correct
from public.lesson_exercises e
join (values
  ('كتبتُ الرسالة.', true),
  ('أكتب الرسالة.', false),
  ('سأكتب الرسالة.', false)
) as o(option_text, is_correct)
on true
where e.question like 'اختر الجملة التي تعبّر%';

-- Linking words
insert into public.lesson_exercise_options (exercise_id, option_text, is_correct)
select e.id, o.option_text, o.is_correct
from public.lesson_exercises e
join (values
  ('فـ', false),
  ('لكن', false),
  ('لأنّ', true)
) as o(option_text, is_correct)
on true
where e.question like 'اختر الأداة المناسبة%';
