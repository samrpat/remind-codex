import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.teal.opacity(0.2), Color.blue.opacity(0.24), Color.black.opacity(0.62)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        scopePicker

                        GlassCard {
                            HStack {
                                metric("Overdue", value: store.overdueReminders.count)
                                Spacer()
                                metric("Due Today", value: store.todaysReminders.count)
                                Spacer()
                                metric("Done", value: store.completionToday)
                            }
                        }

                        if store.todayScope == .today {
                            taskSection(title: "Today's Tasks", items: store.todaysReminders)
                            restOfWeekSection
                        } else {
                            taskSection(title: "This Week", items: store.weekReminders)
                            completionWeekSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Today & Week")
            .presentationDetents([.medium, .large])
        }
    }

    private var scopePicker: some View {
        Picker("Scope", selection: $store.todayScope) {
            Text("Today").tag(DashboardScope.today)
            Text("Week").tag(DashboardScope.week)
        }
        .pickerStyle(.segmented)
    }

    private func taskSection(title: String, items: [ReminderItem]) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)

                if items.isEmpty {
                    Text("No tasks")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(items) { reminder in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(reminder.title)
                                .font(.body.weight(.semibold))
                            Text(detailLine(reminder))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Divider().overlay(Color.white.opacity(0.15))
                    }
                }
            }
        }
    }

    private var restOfWeekSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Rest of Week")
                    .font(.headline)
                ForEach(store.remindersForNext(days: 7).dropFirst(), id: \.date) { day in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(day.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        if day.items.isEmpty {
                            Text("No reminders")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(day.items.prefix(3)) { item in
                                Text("• \(item.title)")
                                    .font(.caption)
                            }
                        }
                    }
                    Divider().overlay(Color.white.opacity(0.12))
                }
            }
        }
    }

    private var completionWeekSection: some View {
        GlassCard {
            HStack {
                metric("Completed This Week", value: store.completionWeek)
                Spacer()
                metric("Due This Week", value: store.weekReminders.count)
            }
        }
    }

    private func metric(_ title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.title3.weight(.bold))
        }
    }

    private func detailLine(_ reminder: ReminderItem) -> String {
        let due = reminder.dueDate?.formatted(date: .abbreviated, time: .shortened) ?? "No due date"
        return "Due: \(due)"
    }
}
