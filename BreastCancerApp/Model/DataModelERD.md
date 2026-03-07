# BreastCancerApp Data Model ERD

This ERD reflects the current project model layout and the profile branch data that still needs to merge cleanly into the app model.

## Entity Relationship Diagram

```mermaid
erDiagram
    PROFILE_USER_PROFILE {
        string firstName
        string lastName
        string profileImageBase64
        string diagnosisDate
        string gender
        int age
        string cancerStage
        string treatmentState
        string treatmentCompletionDate
        bool exerciseNotificationsEnabled
        bool hydrationNotificationsEnabled
        bool appointmentsNotificationsEnabled
        bool medicationsNotificationsEnabled
    }

    USER_PROFILE {
        string id
        string name
        string email
        string treatmentStatus
        string profileImageName
    }

    HEALING_GARDEN_STATS {
        int currentPoints
        int totalPointsNeeded
        int currentLevel
        int nextLevel
    }

    APPOINTMENT_ITEM {
        string id
        string title
        string date
        string time
        bool reminderEnabled
        string note
    }

    MEDICATION_HISTORY_ENTRY {
        string id
        date date
        int taken
        int goal
    }

    MEDICATION {
        string id
        string name
        string note
        string time
        string repeatOption
        bool isTaken
        bool reminderEnabled
    }

    JOURNAL_ENTRY {
        uuid id
        string title
        string body
        date date
        string type
        string question
        string category
    }

    MEMORY {
        string id
        data imageData
        date date
        string note
    }

    HYDRATION_ENTRY {
        uuid id
        int amountML
        date timestamp
    }

    SYMPTOM {
        string id
        string name
        string description
        bool isInUserList
    }

    SYMPTOM_LOG {
        string id
        string symptomId
        string symptomName
        int severity
        string note
        date timestamp
    }

    HEALTH_INSIGHT {
        string id
        string type
        string title
    }

    STORE_ITEM {
        string id
        string name
        string imageName
        int price
        string category
        string baseId
    }

    GARDEN_BASE {
        string id
        string name
        string imageName
        int unlockLevel
        bool isUnlocked
    }

    PLACED_ITEM {
        string id
        string imageName
        float positionX
        float positionY
        float zPosition
    }

    GARDEN_LEVEL_PROGRESS {
        int currentLevel
        int currentPoints
        int pointsNeededForNextLevel
        int dailyCoinsEarned
        string lastResetDateString
    }

    TREATMENT_MODEL {
        string status
    }

    TREATMENT_PHASE_MODEL {
        string treatmentType
        date startDate
        string duration
        string state
    }

    DIAGNOSIS_MODEL {
        date diagnosisDate
        string status
    }

    WAIT_MODEL {
        string status
        int daysWaited
    }

    MEDICATION_HISTORY_ENTRY ||--o{ MEDICATION : contains
    SYMPTOM ||--o{ SYMPTOM_LOG : logged_as
    TREATMENT_MODEL ||--o{ TREATMENT_PHASE_MODEL : contains
    GARDEN_BASE ||--o{ STORE_ITEM : owns
    GARDEN_BASE ||--o{ PLACED_ITEM : contains
    PROFILE_USER_PROFILE ||--|| DIAGNOSIS_MODEL : tracks
    PROFILE_USER_PROFILE ||--o| TREATMENT_MODEL : has
    PROFILE_USER_PROFILE ||--o| WAIT_MODEL : may_have
    USER_PROFILE ||--|| HEALING_GARDEN_STATS : displays
```

## Data Flow To Firebase

```mermaid
flowchart LR
    UI["View Controllers / Data Sources"] --> APPMODELS["AppModels.swift entities"]
    APPMODELS --> MANAGERS["AppointmentManager / MedicationHistory / MemoryStore / JournalStore"]
    MANAGERS --> REPOS["Repository Protocols"]
    REPOS --> LOCAL["UserDefaults repositories"]
    REPOS --> CLOUD["Firestore repositories"]
    CLOUD --> FIREBASE["Firebase Firestore"]

    PROFILE["Profile / Onboarding profile data"] --> APPMODELS
    APPMODELS --> DTO["FirestoreDTOs"]
    DTO --> CLOUD

    APPMODELS --> REMINDERS["Reminder schedulers"]
    REMINDERS --> IOS["UNUserNotificationCenter"]
```

## Production Boundaries

For a production-ready Firebase integration, keep these boundaries explicit:

- `AppModels.swift`: shared app-domain and reusable feature models only
- `FirestoreDTOs.swift`: Firestore transport and document shapes only
- `Firestore*Repository.swift`: persistence and sync rules only
- feature data sources and controllers: UI-local enums, section types, and presentation helpers

This keeps app models stable while allowing Firestore documents to evolve without leaking storage details into the UI layer.

## Firestore Document Model

This view is closer to how Firebase Firestore actually stores the app data.

```mermaid
flowchart TD
    USER["users/{userId}"]

    APPT_COL["appointments/{userId}/{dateKey}"]
    APPT_DOC["Appointment day document
dateKey
items: [AppointmentFirestoreDTO]"]
    APPT_ITEM["AppointmentFirestoreDTO
id
title
date
time
reminderEnabled
reminderOffsets[]
note"]

    MED_COL["medicationHistory/{userId}/{dateKey}"]
    MED_DOC["MedicationHistoryEntryFirestoreDTO
id
date
taken
goal
medications: [MedicationFirestoreDTO]"]
    MED_ITEM["MedicationFirestoreDTO
id
name
note
time
repeatOption
isTaken
reminderEnabled"]

    MEM_COL["memories/{userId}/{memoryId}"]
    MEM_DOC["MemoryFirestoreDTO
id
imageData
date
note"]

    HYD_COL["hydration/{userId}/{entryId}"]
    HYD_DOC["HydrationEntryFirestoreDTO
id
amountML
timestamp"]

    JOURNAL_COL["journals/{userId}/{entryId}"]
    JOURNAL_DOC["JournalEntryFirestoreDTO
id
title
body
date
type
question
category"]

    SYM_COL["symptoms/{userId}/{logId}"]
    SYM_DOC["SymptomLogFirestoreDTO
id
symptomId
symptomName
severity
note
timestamp"]

    USER --> APPT_COL --> APPT_DOC --> APPT_ITEM
    USER --> MED_COL --> MED_DOC --> MED_ITEM
    USER --> MEM_COL --> MEM_DOC
    USER --> HYD_COL --> HYD_DOC
    USER --> JOURNAL_COL --> JOURNAL_DOC
    USER --> SYM_COL --> SYM_DOC
```

## Firestore Sync Mapping

```mermaid
flowchart LR
    APPMODELS["AppModels.swift domain entities"] --> DTOS["FirestoreDTOs.swift"]
    DTOS --> APPT_REPO["FirestoreAppointmentRepository"]
    DTOS --> MED_REPO["FirestoreMedicationHistoryRepository"]
    DTOS --> MEM_REPO["FirestoreMemoryRepository"]
    DTOS --> HYD_REPO["FirestoreHydrationRepository"]
    DTOS --> JOURNAL_REPO["FirestoreJournalRepository"]
    DTOS --> SYM_REPO["FirestoreSymptomRepository"]

    APPT_REPO --> FIRESTORE["Firebase Firestore"]
    MED_REPO --> FIRESTORE
    MEM_REPO --> FIRESTORE
    HYD_REPO --> FIRESTORE
    JOURNAL_REPO --> FIRESTORE
    SYM_REPO --> FIRESTORE

    LOCAL["UserDefaults repositories"] <--> APPT_REPO
    LOCAL <--> MED_REPO
    LOCAL <--> MEM_REPO
    LOCAL <--> HYD_REPO
    LOCAL <--> JOURNAL_REPO
    LOCAL <--> SYM_REPO
```

## Notes For NoSQL Interpretation

- `appointments` are grouped by `dateKey`, and each date document embeds many `AppointmentFirestoreDTO` items.
- `medicationHistory` is also grouped by `dateKey`, and each date document embeds many `MedicationFirestoreDTO` items.
- memories, hydration, journals, and symptom logs are effectively document-per-record collections.
- relationships are enforced by app code and repository logic, not by database foreign keys.
- the central role of `AppModels.swift` is to define the app-domain entities; `FirestoreDTOs.swift` defines the Firestore transport shape.

## AppModels.swift alignment

`AppModels.swift` now acts as the central model map for:

- care/home presentation models
- appointments
- medications
- journal
- symptoms
- insights
- memories and hydration
- garden/store entities
- profile/onboarding profile entities
- treatment/diagnosis/wait journey entities

Remaining non-`AppModels.swift` structs/enums in the project are still mostly controller-local, data-source-local, Firestore DTOs, or feature-internal helper types.
