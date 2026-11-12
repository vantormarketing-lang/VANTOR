alter table public.mrfluent_kids_journey_progress
  add column if not exists wrong_answers jsonb not null default '[]'::jsonb,
  add column if not exists final_quiz_best integer not null default 0 check (final_quiz_best between 0 and 5),
  add column if not exists final_quiz_attempts integer not null default 0 check (final_quiz_attempts >= 0),
  add column if not exists speaking_completed boolean not null default false,
  add column if not exists certificate_earned boolean not null default false,
  add column if not exists certificate_code text,
  add column if not exists certified_at timestamptz;
