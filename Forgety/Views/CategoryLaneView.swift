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
                        ForEach(reminders.prefix(5)) { reminder in
                            HStack {
                                Button {
                                    store.toggleCompleted(reminder.id)
                                } label: {
                                    Image(systemName: "circle")
                                }
                                .buttonStyle(.plain)
                                Text(reminder.title)
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}
