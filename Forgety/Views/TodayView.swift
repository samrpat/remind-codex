import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.teal.opacity(0.2), Color.blue.opacity(0.24), Color.black.opacity(0.62)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        GlassCard {
                            HStack {
                                metric("Overdue", value: store.overdueReminders.count)
                                Spacer()
                                metric("Due Today", value: store.todaysReminders.count)
                                Spacer()
                                metric("Done", value: store.completionToday)
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Today's Tasks")
                                    .font(.headline)

                                if store.todaysReminders.isEmpty {
                                    Text("No tasks due today")
                                        .foregroundStyle(.secondary)
                                } else {
                                    ForEach(store.todaysReminders) { reminder in
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(reminder.title)
                                                .font(.body.weight(.semibold))
                                            Text(detailLine(reminder))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Divider().overlay(Color.white.opacity(0.15))
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Today")
            .presentationDetents([.medium, .large])
        }
    }

    private func metric(_ title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.title3.weight(.bold))
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
