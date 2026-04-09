import SwiftUI

struct CategoryLaneView: View {
    @EnvironmentObject var store: ReminderStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        if let category = store.activeCategory {
            let sectionCount = store.sections(for: category).count
            let reminderCount = store.reminders(for: category).count
            let preview = Array(store.reminders(for: category).prefix(3))

            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label(category.name, systemImage: category.icon)
                        .font(.headline)

                    HStack(spacing: 18) {
                        metric("Reminders", value: "\(reminderCount)")
                        metric("Sections", value: "\(sectionCount)")
                    }

                    if !preview.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Up next")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            ForEach(preview) { item in
                                HStack {
                                    Button {
                                        if let url = item.url { openURL(url) }
                                    } label: {
                                        Text(item.title)
                                            .lineLimit(1)
                                            .foregroundColor(item.url == nil ? .primary : .blue)
                                    }
                                    .buttonStyle(.plain)
                                    Spacer()
                                    Text(item.dueDate?.formatted(date: .abbreviated, time: .shortened) ?? "No due")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(8)
                                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
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
