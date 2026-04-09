# Forgety (iOS SwiftUI Concept)

A swipe-first reminder app focused on ultra-fast input, natural language parsing, and context-aware triggers.

## Included in this scaffold

- Quick Add as the default screen for non-settings categories.
- Gesture navigation:
  - Swipe left/right: cycle Home, Arcade, Settings, and custom categories.
  - Swipe down: Today view.
  - Swipe up: Search + Archive.
- **Actual Settings page** (not a task list) with adjustable app options:
  - Smart parsing, smart repeat, haptics, badge count, iCloud toggle.
  - Default priority/list/repeat and trigger feature toggles.
- Natural language parsing for:
  - Time (`tomorrow at 8pm`, `in 2 hours` via `NSDataDetector` support)
  - Location hints (`home`, `school`)
  - WiFi trigger phrases
  - App mode trigger phrases
- Expanded reminder options inspired by iOS Reminders:
  - Notes, URL, due/start date, all-day, priority, flagged.
  - Repeat rules, alerts, tags, list name, assignee, nested subtasks.
- Notification scheduling service with repeat nudges for incomplete items.
- Simple completion analytics strip (today/week).
- Liquid-glass visual style using material backgrounds + soft depth.

## Project structure

`Forgety/` contains an app-style SwiftUI source layout suitable for dropping into an Xcode iOS target:

- `App/` application entry point + root app view
- `Models/` reminder, trigger, repeat, alert, and settings data models
- `Services/` NLP parser + trigger engine
- `ViewModels/` observable app state and orchestration
- `Views/` swipe container + quick add + today/archive + settings + reminder options sheet
- `Components/` reusable glass card UI

## Next production steps

1. Add persistent storage (SwiftData/Core Data/CloudKit).
2. Implement real geofencing + SSID detection + app-mode hooks.
3. Connect speech dictation via `SFSpeechRecognizer`.
4. Add notification/action handling for complete/snooze directly from alerts.
5. Add parser unit tests + UI snapshot tests.
