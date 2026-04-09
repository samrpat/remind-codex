import SwiftUI

struct CategoryLaneView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        if let category = store.activeCategory {
            let sectionCount = store.sections(for: category).count
            let reminderCount = store.reminders(for: category).count
            let dueSoon = store.reminders(for: category).filter { ($0.dueDate ?? .distantFuture) < Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .distantFuture }.count

            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label(category.name, systemImage: category.icon)
                        .font(.headline)

                    HStack(spacing: 18) {
                        metric("Reminders", value: "\(reminderCount)")
                        metric("Sections", value: "\(sectionCount)")
                        metric("Due Soon", value: "\(dueSoon)")
                    }

                    Button {
                        store.showListDetailSheet = true
                    } label: {
                        Label("Open List", systemImage: "list.bullet")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    private func metric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}
