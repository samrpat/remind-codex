import SwiftUI

struct ReminderListDetailView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.cyan.opacity(0.22), Color.indigo.opacity(0.28), Color.black.opacity(0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        searchBar
                        if let category = store.activeCategory {
                            listControls

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

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search reminders", text: $store.searchQuery)
                .textInputAutocapitalization(.never)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var listControls: some View {
        GlassCard {
            HStack {
                Picker("Sort", selection: $store.listSortMode) {
                    ForEach(ListSortMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                TextField("New section", text: $store.newSectionName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 140)

                Button("Add") {
                    store.addSectionToActiveCategory()
                }
                .buttonStyle(.borderedProminent)
            }
        }
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
