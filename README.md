# Remind Me Faster (iOS SwiftUI Concept)

A swipe-first reminder app focused on ultra-fast input, natural language parsing, and context-aware triggers.

## Included in this scaffold

- Quick Add as the default screen.
- Gesture navigation:
  - Swipe left/right: cycle categories.
  - Swipe down: Today view.
  - Swipe up: Search + Archive.
- Natural language parsing for:
  - Time (`tomorrow at 8pm`, `in 2 hours` via `NSDataDetector` support)
  - Location hints (`home`, `school`)
  - WiFi trigger phrases
  - App mode trigger phrases
- Reminder model with nested subtasks and status.
- Notification scheduling service with repeat nudges for incomplete items.
- Simple completion analytics strip (today/week).
- Liquid-glass visual style using material backgrounds + soft depth.

## Project structure

`RemindMeFaster/` contains an app-style SwiftUI source layout suitable for dropping into an Xcode iOS target:

- `App/` application entry point
- `Models/` reminder and trigger data models
- `Services/` NLP parser + trigger engine
- `ViewModels/` observable app state and orchestration
- `Views/` swipe container + quick add + today/archive screens
- `Components/` reusable glass card UI

## Next production steps

1. Create an Xcode iOS App target and copy these files into the target.
2. Add persistent storage (SwiftData/Core Data/CloudKit).
3. Implement real geofencing + SSID detection + app-mode hooks.
4. Connect speech dictation via `SFSpeechRecognizer`.
5. Add comprehensive parsing tests and notification integration tests.
