# TokenPet Architecture

## Product boundary

TokenPet is not a full billing dashboard. It is a menu bar companion that provides ambient reassurance.

The product loop is:

1. Fetch recent OpenAI usage snapshots
2. Aggregate them into a tiny daily summary
3. Translate that summary into a pet mood
4. Show one glanceable status plus a tiny popover

## Modules

### App
- `TokenPetApp.swift`
- `AppDelegate.swift`
- `TokenPetAppModel.swift`

Owns the menu bar lifecycle, popover installation, and shared observable state.

### Models
- `UsageSummary`
- `DailyUsage`
- `ModelUsage`
- `PetMood`

### Services
- `UsageProviding`
- `DemoUsageProvider`
- `OpenAIUsageProvider`
- `OpenAIUsageClient`
- `MoodEngine`

### Persistence
- `KeychainStore`
- `UsageRepository`
- `SettingsStore`

### UI
- `PopoverRootView`
- `SparklineView`
- `SettingsView`

## Design decisions

### 1. Demo mode is a first-class path
The repo should run immediately after clone. Live OpenAI usage should not block the first experience.

### 2. Menu bar first, no dashboard sprawl
The status item answers the question "should I care right now?" The popover gives only the minimum extra detail.

### 3. Mood engine is small on purpose
v1 uses only four states:
- sleepy
- calm
- active
- overloaded

This is enough to validate the product shape before animation complexity grows.

### 4. Live provider is isolated
`OpenAIUsageClient` sits behind `UsageProviding` so endpoint churn or auth differences do not leak into the UI.

## What to avoid in v1

- multi-provider support
- notifications
- launch agents/background daemons
- deep billing analytics
- team accounts
- plugin systems
