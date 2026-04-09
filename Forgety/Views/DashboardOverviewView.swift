import SwiftUI

struct DashboardOverviewView: View {
    @EnvironmentObject var store: ReminderStore
    @State private var showUpcoming = false

    var body: some View {
        NavigationStack {
            List {
                Section("Summary") {
                    metricRow("Overdue", value: store.overdueReminders.count)
                    metricRow("Due Today", value: store.todaysReminders.count)
                    metricRow("Completed Today", value: store.completionToday)
                    metricRow("Completed This Week", value: store.completionWeek)
                }

                Section("Today's Tasks") {
                    if store.todaysReminders.isEmpty {
                        Text("No tasks due today")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.todaysReminders) { item in
                            Text(item.title)
                        }
                    }
                }

                Section {
                    Button(showUpcoming ? "Hide next days" : "Show next days") {
                        showUpcoming.toggle()
                    }
                }

                if showUpcoming {
                    ForEach(store.remindersForNext(days: 5), id: \.date) { day in
                        Section(day.date.formatted(date: .abbreviated, time: .omitted)) {
                            if day.items.isEmpty {
                                Text("No reminders")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(day.items) { item in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.title)
                                        Text(item.dueDate?.formatted(date: .omitted, time: .shortened) ?? "")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(store.dashboardScope.title)
            .presentationDetents([.large])
        }
    }

    private func metricRow(_ title: String, value: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value)")
                .fontWeight(.semibold)
        }
    }
}
