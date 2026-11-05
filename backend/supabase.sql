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

-- Guide payments through Razorpay. One row per order; status moves created -> sending -> delivered (or failed, retried).
create table if not exists guide_orders (
  order_id text primary key,               -- Razorpay order id (order_...)
  created_at timestamptz default now(),
  email text not null, name text, whatsapp text,
  lead_id uuid,                            -- the student's chance report, when there is one
  amount int,                              -- in paise (49900 = ₹499)
  status text not null default 'created',
  payment_id text,                         -- Razorpay payment id (pay_...)
  paid_at timestamptz
);
create index if not exists guide_orders_created_at_idx on guide_orders (created_at desc);
alter table guide_orders enable row level security;

-- Every time the Guide is emailed (by hand or after a payment)
create table if not exists guide_deliveries (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  email text, name text, lead_id uuid,
  source text,                             -- manual, razorpay, razorpay_webhook
  sent boolean
);
alter table guide_deliveries enable row level security;
