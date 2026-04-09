import SwiftUI

struct CategoryLaneView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        if let category = store.activeCategory {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(category.name, systemImage: category.icon)
                            .font(.headline)
                        Spacer()
                        Picker("Sort", selection: $store.listSortMode) {
                            ForEach(ListSortMode.allCases) { mode in
                                Text(mode.label).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }

                    HStack {
                        TextField("Add section", text: $store.newSectionName)
                            .textFieldStyle(.roundedBorder)
                        Button("Add") {
                            store.addSectionToActiveCategory()
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 14) {
                            ForEach(store.sections(for: category), id: \.self) { section in
                                sectionBlock(category: category, section: section)
                            }
                        }
                    }
                    .frame(maxHeight: 360)
                }
            }
        }
    }

    @ViewBuilder
    private func sectionBlock(category: ReminderCategory, section: String) -> some View {
        let items = store.reminders(for: category, section: section)
        VStack(alignment: .leading, spacing: 8) {
            Text(section)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if items.isEmpty {
                Text("No reminders in this section")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items) { reminder in
                    HStack(alignment: .top, spacing: 8) {
                        Button {
                            store.toggleCompleted(reminder.id)
                        } label: {
                            Image(systemName: reminder.status == .completed ? "checkmark.circle.fill" : "circle")
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(reminder.title)
                                .lineLimit(1)
                            Text(dueLabel(for: reminder))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
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

    private func dueLabel(for reminder: ReminderItem) -> String {
        guard let due = reminder.dueDate else { return "No due date" }
        return "Due: \(due.formatted(date: .abbreviated, time: .shortened))"
    }
}
