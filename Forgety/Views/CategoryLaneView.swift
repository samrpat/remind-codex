import SwiftUI

struct CategoryLaneView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        if let category = store.activeCategory {
            let reminders = store.reminders(for: category)
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label(category.name, systemImage: category.icon)
                        .font(.headline)

                    if reminders.isEmpty {
                        Text("No active reminders")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(reminders.prefix(8)) { reminder in
                            HStack {
                                Button {
                                    store.toggleCompleted(reminder.id)
                                } label: {
                                    Image(systemName: reminder.status == .completed ? "checkmark.circle.fill" : "circle")
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(reminder.title)
                                        .lineLimit(1)
                                    HStack(spacing: 6) {
                                        if reminder.flagged {
                                            Image(systemName: "flag.fill").foregroundStyle(.orange)
                                        }
                                        Text(reminder.priority.displayName)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Button("Options") {
                                    store.selectedReminder = reminder
                                }
                                .font(.caption)
                            }
                        }
                    }
                }
            }
        }
    }
}
