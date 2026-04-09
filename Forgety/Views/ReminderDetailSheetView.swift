import SwiftUI

struct ReminderDetailSheetView: View {
    @EnvironmentObject var store: ReminderStore
    @Environment(\.dismiss) private var dismiss
    @State var reminder: ReminderItem
    @State private var tagsText = ""
    @State private var newSection = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Title & Notes") {
                    TextField("Title", text: $reminder.title)
                    TextField("Notes", text: Binding($reminder.notes, replacingNilWith: ""))
                    TextField("URL", text: Binding(get: { reminder.url?.absoluteString ?? "" }, set: { reminder.url = URL(string: $0) }))
                }

                Section("Schedule") {
                    Toggle("All-day", isOn: $reminder.allDay)
                    DatePicker("Due", selection: Binding($reminder.dueDate, defaultValue: .now), displayedComponents: reminder.allDay ? .date : [.date, .hourAndMinute])
                    Picker("Repeat", selection: $reminder.repeatRule.frequency) {
                        ForEach(RepeatFrequency.allCases) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                }

                Section("List Organization") {
                    Picker("List", selection: $reminder.listName) {
                        ForEach(store.listNames(), id: \.self) { list in
                            Text(list).tag(list)
                        }
                    }
                    Picker("Section", selection: $reminder.sectionName) {
                        ForEach(store.sections(for: store.activeCategory ?? ReminderCategory(name: "", icon: "", tintHex: "")), id: \.self) { section in
                            Text(section).tag(section)
                        }
                    }
                    HStack {
                        TextField("Add new section", text: $newSection)
                        Button("Add") {
                            guard !newSection.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            reminder.sectionName = newSection.trimmingCharacters(in: .whitespaces)
                            newSection = ""
                        }
                    }
                }

                Section("Metadata") {
                    Picker("Priority", selection: $reminder.priority) {
                        ForEach(Priority.allCases) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    TextField("Tags (comma or #tag)", text: $tagsText)
                        .onAppear { tagsText = reminder.tags.joined(separator: ", ") }
                        .onChange(of: tagsText) { newValue in
                            reminder.tags = newValue
                                .replacingOccurrences(of: "#", with: "")
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                        }
                }
            }
            .navigationTitle("Reminder Options")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateReminder(reminder)
                        dismiss()
                    }
                }
            }
        }
    }
}

private extension Binding {
    init(_ source: Binding<Value?>, defaultValue: Value) {
        self.init(get: { source.wrappedValue ?? defaultValue }, set: { source.wrappedValue = $0 })
    }
}

private extension Binding where Value == String {
    init(_ source: Binding<String?>, replacingNilWith replacement: String) {
        self.init(get: { source.wrappedValue ?? replacement }, set: { source.wrappedValue = $0.isEmpty ? nil : $0 })
    }
}
