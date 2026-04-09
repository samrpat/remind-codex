import SwiftUI

struct ReminderListDetailView: View {
    @EnvironmentObject var store: ReminderStore
    @State private var showMiniSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.cyan.opacity(0.22), Color.indigo.opacity(0.28), Color.black.opacity(0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        headerBar

                        if showMiniSettings {
                            miniSettingsPanel
                        }

                        if let category = store.activeCategory {
                            if store.searchQuery.isEmpty {
                                ForEach(store.sections(for: category), id: \.self) { section in
                                    GlassCard {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text(section)
                                                .font(.headline)
                                                .foregroundStyle(.secondary)
                                            rows(store.reminders(for: category, section: section))
                                        }
                                    }
                                }
                            } else {
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Results")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                        rows(store.filteredRemindersForActiveCategory())
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(store.activeCategory?.name ?? "List")
            .presentationDetents([.large])
        }
    }

    private var headerBar: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search reminders", text: $store.searchQuery)
                    .textInputAutocapitalization(.never)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    showMiniSettings.toggle()
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.headline)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private var miniSettingsPanel: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("List settings")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    sortChip(.manual)
                    sortChip(.dueDate)
                }

                HStack {
                    TextField("New section", text: $store.newSectionName)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        store.addSectionToActiveCategory()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func sortChip(_ mode: ListSortMode) -> some View {
        Button {
            store.listSortMode = mode
        } label: {
            Text(mode.label)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(store.listSortMode == mode ? Color.accentColor.opacity(0.26) : Color.white.opacity(0.08), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func rows(_ reminders: [ReminderItem]) -> some View {
        if reminders.isEmpty {
            Text("No reminders")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            ForEach(reminders) { reminder in
                HStack(alignment: .top) {
                    Button {
                        store.toggleCompleted(reminder.id)
                    } label: {
                        Image(systemName: reminder.status == .completed ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(reminder.title)
                            .font(.body.weight(.semibold))
                        Text(dueLabel(reminder))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button("Options") {
                        store.selectedReminder = reminder
                    }
                    .font(.caption)
                }
                Divider().overlay(Color.white.opacity(0.15))
            }
        }
    }

    private func dueLabel(_ reminder: ReminderItem) -> String {
        guard let due = reminder.dueDate else { return "No due date" }
        return "Due \(due.formatted(date: .abbreviated, time: .shortened))"
    }
}
