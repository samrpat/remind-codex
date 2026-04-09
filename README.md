# Forgety (iOS SwiftUI Concept)

A swipe-first reminder app focused on ultra-fast input, natural language parsing, and focus-mode-aware reminders.

## Included in this scaffold

- Quick Add as the default screen for non-settings categories, with one-tap time chips (`9a`, `3p`) and day shift controls (`-` / `+`).
- Gesture navigation:
  - Swipe left/right: cycle Home, Arcade, Settings, and custom categories.
  - Today/Week opens by tap (no vertical swipe dependency).
- Top search bar on the homepage for quick filtering.
- Homepage list card now includes the first few upcoming reminders with inline due date.
- Tapping a reminder title opens its URL if present.
- List card opens into a dedicated **list detail view** with:
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
- Simplified Settings focused on defaults + **Focus Mode trigger**.
- Natural language parsing now supports:
  - due date/time phrases,
  - priority hints,
  - repeat hints,
  - section hints,
  - hashtags (`#tag`) mapped to reminder tags,
  - cleanup/removal of NL tokens from final reminder title with auto-capitalized output.
- Reminder options use list/section pickers, removed assigned-to/flagged/start-time fields.

## Project structure

`Forgety/` contains an app-style SwiftUI source layout suitable for dropping into an Xcode iOS target.
