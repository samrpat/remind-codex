import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.todaysReminders) { reminder in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(reminder.title)
                            .font(.headline)
                        Text(detailLine(reminder))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Today")
            .presentationDetents([.medium, .large])
        }
    }

    private func detailLine(_ reminder: ReminderItem) -> String {
        let triggerText = triggerLabel(reminder.trigger)
        let due = reminder.dueDate?.formatted(date: .abbreviated, time: .shortened) ?? "No due date"
        return "\(triggerText) • Due: \(due)"
    }

    private func triggerLabel(_ trigger: ReminderTrigger) -> String {
        switch trigger {
        case .time(let date):
            return date.formatted(date: .omitted, time: .shortened)
        case .location(let loc):
            return "Location: \(loc.label)"
        case .wifi(let ssid):
            return "WiFi: \(ssid)"
        case .appMode(let mode):
            return "Mode: \(mode)"
        case .arrival(let loc):
            return "On arrival: \(loc.label)"
        case .departure(let loc):
            return "On departure: \(loc.label)"
        case .none:
            return "Quick reminder"
        }
    }
}
