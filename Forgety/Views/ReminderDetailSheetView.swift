import SwiftUI

struct ReminderDetailSheetView: View {
    @EnvironmentObject var store: ReminderStore
    @Environment(\.dismiss) private var dismiss
    @State var reminder: ReminderItem
    @State private var tagsText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Title & Notes") {
                    TextField("Title", text: $reminder.title)
                    TextField("Notes", text: Binding($reminder.notes, replacingNilWith: ""))
                    TextField("URL", text: Binding(
                        get: { reminder.url?.absoluteString ?? "" },
                        set: { reminder.url = URL(string: $0) }
                    ))
                }

                Section("Schedule") {
                    Toggle("All-day", isOn: $reminder.allDay)
                    DatePicker("Due", selection: Binding($reminder.dueDate, defaultValue: .now), displayedComponents: reminder.allDay ? .date : [.date, .hourAndMinute])
                    DatePicker("Start", selection: Binding($reminder.startDate, defaultValue: .now), displayedComponents: reminder.allDay ? .date : [.date, .hourAndMinute])
                    Picker("Repeat", selection: $reminder.repeatRule.frequency) {
                        ForEach(RepeatFrequency.allCases) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                }

                Section("Metadata") {
                    Picker("Priority", selection: $reminder.priority) {
                        ForEach(Priority.allCases) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    Toggle("Flagged", isOn: $reminder.flagged)
                    TextField("List", text: $reminder.listName)
                    TextField("Section", text: $reminder.sectionName)
                    TextField("Assigned to", text: Binding($reminder.assignedTo, replacingNilWith: ""))
                    TextField("Tags (comma separated)", text: $tagsText)
                        .onAppear { tagsText = reminder.tags.joined(separator: ", ") }
                        .onChange(of: tagsText) { newValue in
                            reminder.tags = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
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
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}

private extension Binding where Value == String {
    init(_ source: Binding<String?>, replacingNilWith replacement: String) {
        self.init(
            get: { source.wrappedValue ?? replacement },
            set: { source.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}
