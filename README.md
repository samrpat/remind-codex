# Forgety (iOS SwiftUI Concept)

A swipe-first reminder app focused on ultra-fast input, natural language parsing, and context-aware triggers.

## Included in this scaffold

- Quick Add as the default screen for non-settings categories, with one-tap time chips (`9a`, `3p`) and day shift controls (`-` / `+`).
- Gesture navigation:
  - Swipe left/right: cycle Home, Arcade, Settings, and custom categories.
  - Swipe down: Today view.
- Top search bar on the homepage for quick filtering (instead of a separate search screen).
- List card on homepage opens into a dedicated **list detail view** styled with the same liquid-glass theme as home/settings, with:
  - sectioned list layout,
  - section creation,
  - sort by due date/manual,
  - inline due dates and options actions.
- Tapable Today/Week dashboard cards that open overview with a modern liquid-glass layout:
  - overdue vs due today counts,
  - completion stats,
  - today task list,
  - collapsible next-days timeline (next 5 days).
- Simplified Settings page with themed glass cards/toggles and clearly-labeled defaults + trigger configuration:
  - Smart parsing, smart repeat, haptics.
  - Default priority/repeat/list values.
  - Location trigger radius, WiFi SSIDs, and focus-mode trigger name.
- Natural language parsing for:
  - Time (`tomorrow at 8pm`, `in 2 hours`, `due 3pm tmrw`)
  - Location hints (`home`, `school`)
  - WiFi trigger phrases
  - App mode trigger phrases
- Expanded reminder options inspired by iOS Reminders:
  - Notes, URL, due/start date, all-day, priority, flagged.
  - Repeat rules, alerts, tags, list name/section, assignee, nested subtasks.

## Project structure

`Forgety/` contains an app-style SwiftUI source layout suitable for dropping into an Xcode iOS target:

- `App/` application entry point + root app view
- `Models/` reminder, trigger, repeat, alert, and settings data models
- `Services/` NLP parser + trigger engine
- `ViewModels/` observable app state and orchestration
- `Views/` swipe container + quick add + today + list detail + dashboard + settings + reminder options sheet
- `Components/` reusable glass card UI
