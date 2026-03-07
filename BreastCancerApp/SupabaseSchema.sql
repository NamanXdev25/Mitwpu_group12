-- Transitional Supabase schema for the current app migration stage.
-- This matches the repository layer already added in the app.
--
-- Important:
-- 1. This keeps the current offline-first snapshot behavior.
-- 2. `medication_history_snapshots` is transitional, not the final normalized design.
-- 3. Full RLS using auth.uid() requires real Supabase auth. The current app code still uses a
--    generated local UUID (`SupabaseUserContext.userId`) for migration/testing.

create extension if not exists pgcrypto;

create table if not exists appointments (
    id uuid primary key,
    user_id uuid not null,
    title text not null,
    doctor text,
    location text,
    note text,
    appointment_at timestamptz not null,
    reminder_enabled boolean not null default false,
    created_at timestamptz,
    updated_at timestamptz
);

create index if not exists appointments_user_id_idx
    on appointments (user_id);

create index if not exists appointments_user_time_idx
    on appointments (user_id, appointment_at desc);

create table if not exists appointment_reminders (
    id uuid primary key,
    user_id uuid not null,
    appointment_id uuid not null references appointments(id) on delete cascade,
    offset_minutes integer not null,
    created_at timestamptz
);

create index if not exists appointment_reminders_user_id_idx
    on appointment_reminders (user_id);

create index if not exists appointment_reminders_appointment_id_idx
    on appointment_reminders (appointment_id);

create unique index if not exists appointment_reminders_unique_offset_idx
    on appointment_reminders (appointment_id, offset_minutes);

create table if not exists medication_history_snapshots (
    id text primary key,
    user_id uuid not null,
    date_key text not null,
    date_epoch double precision not null,
    medications jsonb not null default '[]'::jsonb,
    taken integer not null default 0,
    goal integer not null default 0,
    updated_at timestamptz
);

create index if not exists medication_history_snapshots_user_id_idx
    on medication_history_snapshots (user_id);

create unique index if not exists medication_history_snapshots_user_date_key_idx
    on medication_history_snapshots (user_id, date_key);

create table if not exists medication_items (
    id text primary key,
    user_id uuid not null,
    date_key text not null,
    medication_id text not null,
    name text not null,
    note text not null default '',
    time text not null,
    repeat_option text not null,
    is_taken boolean not null default false,
    reminder_enabled boolean not null default false,
    updated_at timestamptz
);

create index if not exists medication_items_user_id_idx
    on medication_items (user_id);

create index if not exists medication_items_user_date_key_idx
    on medication_items (user_id, date_key desc);

create table if not exists medication_plans (
    id text primary key,
    user_id uuid not null,
    name text not null,
    note text not null default '',
    time text not null,
    repeat_option text not null,
    reminder_enabled boolean not null default false,
    is_active boolean not null default true,
    created_at timestamptz,
    updated_at timestamptz
);

create index if not exists medication_plans_user_id_idx
    on medication_plans (user_id);

create table if not exists medication_daily_status (
    id text primary key,
    user_id uuid not null,
    date_key text not null,
    date_epoch double precision not null,
    medication_id text not null,
    is_scheduled boolean not null default true,
    is_taken boolean not null default false,
    taken_at timestamptz,
    updated_at timestamptz
);

create index if not exists medication_daily_status_user_id_idx
    on medication_daily_status (user_id);

create index if not exists medication_daily_status_user_date_key_idx
    on medication_daily_status (user_id, date_key desc);

create unique index if not exists medication_daily_status_user_date_medication_idx
    on medication_daily_status (user_id, date_key, medication_id);

create table if not exists memories (
    id text primary key,
    user_id uuid not null,
    image_data_base64 text,
    memory_date timestamptz not null,
    note text,
    created_at timestamptz
);

create index if not exists memories_user_id_idx
    on memories (user_id);

create index if not exists memories_user_date_idx
    on memories (user_id, memory_date desc);

create table if not exists hydration_daily_status (
    id text primary key,
    user_id uuid not null,
    date_key text not null,
    date_epoch double precision not null,
    consumed_ml integer not null default 0 check (consumed_ml >= 0),
    goal_ml integer not null default 3000 check (goal_ml > 0),
    updated_at timestamptz
);

create index if not exists hydration_daily_status_user_id_idx
    on hydration_daily_status (user_id);

create unique index if not exists hydration_daily_status_user_date_key_idx
    on hydration_daily_status (user_id, date_key);

create table if not exists journals (
    id uuid primary key,
    user_id uuid not null,
    title text not null,
    body text not null,
    type text not null,
    question text,
    category text,
    journal_date timestamptz not null,
    created_at timestamptz,
    updated_at timestamptz
);

create index if not exists journals_user_id_idx
    on journals (user_id);

create index if not exists journals_user_date_idx
    on journals (user_id, journal_date desc);

create table if not exists symptom_logs (
    id text primary key,
    user_id uuid not null,
    symptom_id text not null,
    symptom_name text not null,
    severity integer not null,
    note text not null default '',
    logged_at timestamptz not null,
    created_at timestamptz
);

create index if not exists symptom_logs_user_id_idx
    on symptom_logs (user_id);

create index if not exists symptom_logs_user_logged_idx
    on symptom_logs (user_id, logged_at desc);

create table if not exists symptom_user_preferences (
    id uuid primary key,
    user_id uuid not null unique,
    user_symptom_ids jsonb not null default '[]'::jsonb,
    updated_at timestamptz
);

create table if not exists breathing_favorites (
    id uuid primary key,
    user_id uuid not null,
    title text not null,
    created_at timestamptz
);

create index if not exists breathing_favorites_user_id_idx
    on breathing_favorites (user_id);

create unique index if not exists breathing_favorites_user_title_idx
    on breathing_favorites (user_id, title);

-- RLS setup.
-- Do not enable these for runtime until the app uses real Supabase auth instead of a generated local UUID.

alter table appointments enable row level security;
alter table appointment_reminders enable row level security;
alter table medication_history_snapshots enable row level security;
alter table medication_items enable row level security;
alter table medication_plans enable row level security;
alter table medication_daily_status enable row level security;
alter table memories enable row level security;
alter table hydration_daily_status enable row level security;
alter table journals enable row level security;
alter table symptom_logs enable row level security;
alter table symptom_user_preferences enable row level security;
alter table breathing_favorites enable row level security;

create policy "appointments_owner_all"
on appointments
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "appointment_reminders_owner_all"
on appointment_reminders
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "medication_history_snapshots_owner_all"
on medication_history_snapshots
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "medication_items_owner_all"
on medication_items
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "medication_plans_owner_all"
on medication_plans
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "medication_daily_status_owner_all"
on medication_daily_status
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "memories_owner_all"
on memories
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "hydration_daily_status_owner_all"
on hydration_daily_status
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "journals_owner_all"
on journals
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "symptom_logs_owner_all"
on symptom_logs
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "symptom_user_preferences_owner_all"
on symptom_user_preferences
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);

create policy "breathing_favorites_owner_all"
on breathing_favorites
for all
using (auth.uid()::uuid = user_id)
with check (auth.uid()::uuid = user_id);
