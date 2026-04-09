import Foundation
import SwiftUI
import Combine

enum QuickTimePreset: String, CaseIterable, Identifiable {
    case nineAM
    case threePM

    var id: String { rawValue }

    var label: String {
        switch self {
        case .nineAM: return "9a"
        case .threePM: return "3p"
        }
    }

    var hour: Int {
        switch self {
        case .nineAM: return 9
        case .threePM: return 15
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

    @Published var quickDayOffset: Int = 0
    @Published var selectedQuickTimePreset: QuickTimePreset?

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
        guard let selectedQuickTimePreset else { return nil }
        let baseDate = Calendar.current.date(byAdding: .day, value: quickDayOffset, to: .now) ?? .now
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: baseDate)
        comps.hour = selectedQuickTimePreset.hour
        comps.minute = 0
        return Calendar.current.date(from: comps)
    }

    var dayOffsetLabel: String {
        switch quickDayOffset {
        case 0: return "Today"
        case 1: return "Tomorrow"
        case -1: return "Yesterday"
        default:
            return quickDayOffset > 0 ? "+\(quickDayOffset)d" : "\(quickDayOffset)d"
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
        selectedQuickTimePreset = nil
        quickDayOffset = 0
    }

    func toggleQuickTimePreset(_ preset: QuickTimePreset) {
        selectedQuickTimePreset = selectedQuickTimePreset == preset ? nil : preset
    }

    func adjustQuickDayOffset(by delta: Int) {
        quickDayOffset = max(-30, min(30, quickDayOffset + delta))
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
}
