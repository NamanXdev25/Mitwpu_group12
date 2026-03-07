# Supabase Migration Plan

## Current Status

The app now has a staged backend boundary:

- `AppBackend.swift`
- `RepositoryFactory.swift`
- `SupabaseSupport.swift`
- `SupabaseDTOs.swift`
- `SupabaseRepositories.swift`
- `SupabaseMigrationService.swift`

Managers and stores now resolve repositories through `RepositoryFactory`, so the backend can switch without rewriting controllers first.

## What Works In This Stage

- local-first persistence remains the offline source of truth
- Supabase repositories mirror the current Firebase repository pattern:
  - load cached local data first
  - then sync from cloud into local
  - save locally first
  - then push the latest snapshot to cloud
- one-time local-to-Supabase migration hook exists

## Required Configuration

Set these keys in `Info.plist` or `UserDefaults`:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SCHEMA` optional, defaults to `public`

Select backend:

```swift
AppBackend.setCurrent(.supabase)
```

## Supabase Tables Expected In This Stage

- `appointments`
- `appointment_reminders`
- `medication_history_snapshots`
- `medication_items`
- `medication_plans`
- `medication_daily_status`
- `memories`
- `hydration_daily_status`
- `journals`
- `symptom_logs`
- `symptom_user_preferences`
- `breathing_favorites`

## Important Transitional Note

`medication_history_snapshots` is a compatibility table for this migration phase.

It preserves the current medication feature behavior and offline sync model while the app still uses:

- `Medication`
- `MedicationHistoryEntry`
- daily grouped history

The final normalized Supabase design should still move toward:

- `medications`
- `medication_logs`

## Remaining Work Before Full Cutover

1. Create the actual Supabase tables and RLS policies.
2. Add a real authenticated Supabase `user_id` flow instead of the temporary local UUID.
3. Replace transitional medication snapshots with normalized medication tables.
4. Migrate profile storage to Supabase.
5. Validate reminder resync behavior against Supabase-backed data.
6. Run a full Xcode build and feature test on device/simulator.
