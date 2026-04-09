import Foundation
import SwiftUI
import Combine

enum QuickDuePreset: String, CaseIterable, Identifiable {
    case none
    case inOneHour
    case tonight
    case tomorrowMorning
    case tomorrowThreePM

    var id: String { rawValue }

    var label: String {
        switch self {
        case .none: return "No Due"
        case .inOneHour: return "+1h"
        case .tonight: return "Tonight"
        case .tomorrowMorning: return "Tomorrow 9a"
        case .tomorrowThreePM: return "Tomorrow 3p"
        }
    }
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
    @Published var selectedQuickPreset: QuickDuePreset = .none

    let parser = NaturalLanguageParser()
    let triggerEngine = ContextTriggerEngine()

    var activeCategories: [ReminderCategory] { categories }

    var activeCategory: ReminderCategory? {
        guard activeCategoryIndex >= 0, activeCategoryIndex < categories.count else { return nil }
        return categories[activeCategoryIndex]
    }

    var isSettingsPageActive: Bool {
        activeCategory?.name == "Settings"
    }

    var quickPresetDueDate: Date? {
        dueDate(for: selectedQuickPreset)
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

        var reminder = ReminderItem(
            title: parsed.cleanedTitle,
            categoryID: category.id,
            listName: settings.defaultListName,
            dueDate: dueDate,
            trigger: trigger,
            priority: settings.defaultPriority,
            repeatRule: ReminderRepeatRule(frequency: settings.defaultRepeat, interval: 1)
        )
        reminder.flagged = reminder.priority == .high

        reminders.insert(reminder, at: 0)
        triggerEngine.scheduleNotification(for: reminder)
        quickInput = ""
        selectedQuickPreset = .none
    }

    func toggleQuickPreset(_ preset: QuickDuePreset) {
        selectedQuickPreset = selectedQuickPreset == preset ? .none : preset
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

    func addCategory(name: String, icon: String = "folder.fill", tintHex: String = "#22C55E") {
        categories.append(ReminderCategory(name: name, icon: icon, tintHex: tintHex))
    }

    func reminders(for category: ReminderCategory) -> [ReminderItem] {
        reminders.filter { $0.categoryID == category.id && $0.status == .active }
    }

    private func categoryForHint(_ hint: String?) -> ReminderCategory? {
        guard let hint else { return nil }
        return categories.first { $0.name.lowercased() == hint.lowercased() }
    }

    private func triggerDate(from trigger: ReminderTrigger) -> Date? {
        if case .time(let date) = trigger { return date }
        return nil
    }

    private func dueDate(for preset: QuickDuePreset) -> Date? {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        switch preset {
        case .none:
            return nil
        case .inOneHour:
            return Calendar.current.date(byAdding: .hour, value: 1, to: .now)
        case .tonight:
            comps.hour = 20
            comps.minute = 0
            return Calendar.current.date(from: comps)
        case .tomorrowMorning:
            guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) else { return nil }
            var tomorrowComps = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
            tomorrowComps.hour = 9
            tomorrowComps.minute = 0
            return Calendar.current.date(from: tomorrowComps)
        case .tomorrowThreePM:
            guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) else { return nil }
            var tomorrowComps = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
            tomorrowComps.hour = 15
            tomorrowComps.minute = 0
            return Calendar.current.date(from: tomorrowComps)
        }
    }
}
