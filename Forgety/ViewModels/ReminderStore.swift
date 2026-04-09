import Foundation
import SwiftUI
import Combine

enum QuickTimePreset: String, CaseIterable, Identifiable {
    case nineAM
    case threePM

    var id: String { rawValue }
    var label: String { self == .nineAM ? "9a" : "3p" }
    var hour: Int { self == .nineAM ? 9 : 15 }
}

enum ListSortMode: String, CaseIterable, Identifiable {
    case manual
    case dueDate

    var id: String { rawValue }
    var label: String { self == .manual ? "Manual" : "Due Date" }
}

@MainActor
final class ReminderStore: ObservableObject {
    @Published var categories: [ReminderCategory] = []
    @Published var reminders: [ReminderItem] = []
    @Published var quickInput: String = ""
    @Published var activeCategoryIndex = 0
    @Published var showTodaySheet = false
    @Published var showArchiveSheet = false
    @Published var settings = AppSettings()
    @Published var selectedReminder: ReminderItem?

    @Published var quickDayOffset: Int = 0
    @Published var selectedQuickTimePreset: QuickTimePreset?

    @Published var newSectionName: String = ""
    @Published var selectedSectionByCategory: [UUID: String] = [:]
    @Published var listSortMode: ListSortMode = .dueDate

    let parser = NaturalLanguageParser()
    let triggerEngine = ContextTriggerEngine()

    var activeCategory: ReminderCategory? {
        guard activeCategoryIndex >= 0, activeCategoryIndex < categories.count else { return nil }
        return categories[activeCategoryIndex]
    }

    var isSettingsPageActive: Bool {
        activeCategory?.name == "Settings"
    }

    var quickPresetDueDate: Date? {
        guard let selectedQuickTimePreset else { return nil }
        let baseDate = Calendar.current.date(byAdding: .day, value: quickDayOffset, to: .now) ?? .now
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: baseDate)
        comps.hour = selectedQuickTimePreset.hour
        comps.minute = 0
        return Calendar.current.date(from: comps)
    }

    var quickDaySummary: String {
        let baseDate = Calendar.current.date(byAdding: .day, value: quickDayOffset, to: .now) ?? .now
        let weekday = baseDate.formatted(.dateTime.weekday(.abbreviated))
        switch quickDayOffset {
        case 0: return "Today • \(weekday)"
        case 1: return "Tomorrow • \(weekday)"
        default: return "\(quickDayOffset >= 0 ? "+\(quickDayOffset)" : "\(quickDayOffset)")d • \(weekday)"
        }
    }

    var todaysReminders: [ReminderItem] {
        reminders.filter { reminder in
            if let dueDate = reminder.dueDate {
                return Calendar.current.isDateInToday(dueDate)
            }
            if case .time(let date) = reminder.trigger {
                return Calendar.current.isDateInToday(date)
            }
            return reminder.status == .active
        }
    }

    var archivedReminders: [ReminderItem] {
        reminders.filter { $0.status != .active }
    }

    func bootstrap() async {
        if categories.isEmpty {
            categories = [
                ReminderCategory(name: "Home", icon: "house.fill", tintHex: "#4A90E2", isSystem: true),
                ReminderCategory(name: "Arcade", icon: "gamecontroller.fill", tintHex: "#A855F7", isSystem: true),
                ReminderCategory(name: "Settings", icon: "gearshape.fill", tintHex: "#64748B", isSystem: true)
            ]
            categories.forEach { selectedSectionByCategory[$0.id] = "General" }
        }
        await triggerEngine.requestPermissions()
    }

    func cycleCategory(direction: Int) {
        guard !categories.isEmpty else { return }
        let count = categories.count
        activeCategoryIndex = (activeCategoryIndex + direction + count) % count
    }

    func createReminderFromQuickInput() {
        let text = quickInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let parsed = settings.smartParsingEnabled ? parser.parse(text) : ParsedReminderInput(cleanedTitle: text, categoryHint: nil, trigger: .none)
        let fallbackCategory = categories.first { $0.name != "Settings" }
        let category = categoryForHint(parsed.categoryHint) ?? activeCategory ?? fallbackCategory

        guard let category else { return }
        let parserDate = triggerDate(from: parsed.trigger)
        let dueDate = quickPresetDueDate ?? parserDate
        let trigger: ReminderTrigger = dueDate.map { .time($0) } ?? parsed.trigger

        let chosenSection = selectedSectionByCategory[category.id] ?? "General"
        var reminder = ReminderItem(
            title: parsed.cleanedTitle,
            categoryID: category.id,
            listName: settings.defaultListName,
            sectionName: chosenSection,
            dueDate: dueDate,
            trigger: trigger,
            priority: settings.defaultPriority,
            repeatRule: ReminderRepeatRule(frequency: settings.defaultRepeat, interval: 1)
        )
        reminder.flagged = reminder.priority == .high

        reminders.insert(reminder, at: 0)
        triggerEngine.scheduleNotification(for: reminder)
        quickInput = ""
        selectedQuickTimePreset = nil
        quickDayOffset = 0
    }

    func toggleQuickTimePreset(_ preset: QuickTimePreset) {
        selectedQuickTimePreset = selectedQuickTimePreset == preset ? nil : preset
    }

    func adjustQuickDayOffset(by delta: Int) {
        quickDayOffset = max(-30, min(30, quickDayOffset + delta))
    }

    func addSectionToActiveCategory() {
        guard let category = activeCategory else { return }
        let section = newSectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !section.isEmpty else { return }
        selectedSectionByCategory[category.id] = section
        newSectionName = ""
    }

    func sections(for category: ReminderCategory) -> [String] {
        let existing = reminders
            .filter { $0.categoryID == category.id }
            .map(\.sectionName)
        let merged = Set(existing + [selectedSectionByCategory[category.id] ?? "General", "General"])
        return Array(merged).sorted()
    }

    func reminders(for category: ReminderCategory, section: String? = nil) -> [ReminderItem] {
        let filtered = reminders.filter {
            $0.categoryID == category.id && $0.status == .active && (section == nil || $0.sectionName == section)
        }
        switch listSortMode {
        case .manual:
            return filtered
        case .dueDate:
            return filtered.sorted { lhs, rhs in
                switch (lhs.dueDate, rhs.dueDate) {
                case let (l?, r?): return l < r
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil): return lhs.createdAt > rhs.createdAt
                }
            }
        }
    }

    func toggleCompleted(_ id: UUID) {
        guard let idx = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[idx].status = reminders[idx].status == .completed ? .active : .completed
        if reminders[idx].status == .active && settings.smartRepeatEnabled {
            triggerEngine.enqueueRepeatIfIncomplete(for: reminders[idx])
        }
    }

    func updateReminder(_ reminder: ReminderItem) {
        guard let idx = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[idx] = reminder
    }

    private func categoryForHint(_ hint: String?) -> ReminderCategory? {
        guard let hint else { return nil }
        return categories.first { $0.name.lowercased() == hint.lowercased() }
    }

    private func triggerDate(from trigger: ReminderTrigger) -> Date? {
        if case .time(let date) = trigger { return date }
        return nil
    }
}
