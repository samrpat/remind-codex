# Forgety (iOS SwiftUI Concept)

A swipe-first reminder app focused on ultra-fast input, natural language parsing, and context-aware triggers.

## Included in this scaffold

- Quick Add as the default screen for non-settings categories, with one-tap time chips (`9a`, `3p`) and day shift controls (`-` / `+`).
- Gesture navigation:
  - Swipe left/right: cycle Home, Arcade, Settings, and custom categories.
  - Today/Week opens by tap (no vertical swipe dependency).
- Top search bar on the homepage for quick filtering (instead of a separate search screen).
- List card on homepage opens into a dedicated **list detail view** styled with the same liquid-glass theme as home/settings, with:
  - sectioned list layout,
  - mini settings panel for sort mode + adding sections,
  - themed manual/due-date sort chips,
  - inline due dates and options actions.
- Unified **Today & Week** view:
  - segmented Today/Week control,
  - overdue + due today + completions metrics,
  - today tasks,
  - rest-of-week preview inside Today mode,
  - full week task/completion view in Week mode.
- Simplified Settings page with themed glass cards/toggles and clearly-labeled defaults + trigger configuration.
- Natural language parsing for:
  - Time (`tomorrow at 8pm`, `in 2 hours`, `due 3pm tmrw`)
  - Location hints (`home`, `school`)
  - WiFi trigger phrases
  - App mode trigger phrases
- Expanded reminder options inspired by iOS Reminders.

## Project structure

`Forgety/` contains an app-style SwiftUI source layout suitable for dropping into an Xcode iOS target:

- `App/` application entry point + root app view
- `Models/` reminder, trigger, repeat, alert, and settings data models
- `Services/` NLP parser + trigger engine
- `ViewModels/` observable app state and orchestration
- `Views/` swipe container + quick add + today/week + list detail + settings + reminder options sheet
- `Components/` reusable glass card UI
