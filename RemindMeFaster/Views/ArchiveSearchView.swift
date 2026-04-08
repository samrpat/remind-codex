import SwiftUI

struct ArchiveSearchView: View {
    @EnvironmentObject var store: ReminderStore
    @State private var query = ""

    var results: [ReminderItem] {
        let all = store.archivedReminders
        guard !query.isEmpty else { return all }
        return all.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List(results) { reminder in
                Text(reminder.title)
            }
            .searchable(text: $query, prompt: "Search completed + archived")
            .navigationTitle("Search & Archive")
            .presentationDetents([.medium, .large])
        }
    }
}
