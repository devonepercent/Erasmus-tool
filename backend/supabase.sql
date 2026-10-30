-- Run this once in Supabase > SQL Editor > New query > Run
create table if not exists leads (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  name text, email text, whatsapp text,
  cgpa numeric, target_intake text, programmes text[],
  english_score text, college text,
  experience jsonb, research text[], extracurricular text[],
  cv_text text,
  admission_pct int, scholarship_pct int,
  breakdown jsonb, gaps jsonb, programme_matches jsonb,
  uplift_pct int, lead_tag text,
  leaderboard_consent boolean default false,
  city text
);
create index if not exists leads_created_at_idx on leads (created_at desc);

-- IMPORTANT: lock the table. With this on and no policies, the public website key cannot read or write
-- any student's details. Only this server (which uses the secret service_role key) can.
alter table leads enable row level security;
