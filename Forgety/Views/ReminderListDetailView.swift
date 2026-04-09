import SwiftUI

struct ReminderListDetailView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search reminders", text: $store.searchQuery)
                        .textInputAutocapitalization(.never)
                }
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                if let category = store.activeCategory {
                    listControls(category)

                    List {
                        if store.searchQuery.isEmpty {
                            ForEach(store.sections(for: category), id: \.self) { section in
                                Section(section) {
                                    rows(store.reminders(for: category, section: section))
                                }
                            }
                        } else {
                            Section("Results") {
                                rows(store.filteredRemindersForActiveCategory())
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .padding(.horizontal)
            .navigationTitle(store.activeCategory?.name ?? "List")
            .presentationDetents([.large])
        }
    }

    private func listControls(_ category: ReminderCategory) -> some View {
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
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private func rows(_ reminders: [ReminderItem]) -> some View {
        ForEach(reminders) { reminder in
            HStack(alignment: .top) {
                Button {
                    store.toggleCompleted(reminder.id)
                } label: {
                    Image(systemName: reminder.status == .completed ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 2) {
                    Text(reminder.title)
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
        }
    }

    private func dueLabel(_ reminder: ReminderItem) -> String {
        guard let due = reminder.dueDate else { return "No due date" }
        return "Due \(due.formatted(date: .abbreviated, time: .shortened))"
    }
}
