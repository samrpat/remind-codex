import Foundation
import SwiftUI

@MainActor
final class ReminderStore: ObservableObject {
    @Published var categories: [ReminderCategory] = []
    @Published var reminders: [ReminderItem] = []
    @Published var quickInput: String = ""
    @Published var activeCategoryIndex = 0
    @Published var showTodaySheet = false
    @Published var showArchiveSheet = false

    let parser = NaturalLanguageParser()
    let triggerEngine = ContextTriggerEngine()

    var activeCategories: [ReminderCategory] { categories }

    var activeCategory: ReminderCategory? {
        guard activeCategoryIndex >= 0, activeCategoryIndex < categories.count else { return nil }
        return categories[activeCategoryIndex]
    }

    var todaysReminders: [ReminderItem] {
        reminders.filter { reminder in
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

        let parsed = parser.parse(text)
        let category = categoryForHint(parsed.categoryHint) ?? activeCategory ?? categories.first

        guard let category else { return }
        let reminder = ReminderItem(title: parsed.cleanedTitle, categoryID: category.id, trigger: parsed.trigger)
        reminders.insert(reminder, at: 0)
        triggerEngine.scheduleNotification(for: reminder)
        quickInput = ""
    }

    func toggleCompleted(_ id: UUID) {
        guard let idx = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[idx].status = reminders[idx].status == .completed ? .active : .completed
        if reminders[idx].status == .active {
            triggerEngine.enqueueRepeatIfIncomplete(for: reminders[idx])
        }
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
}
