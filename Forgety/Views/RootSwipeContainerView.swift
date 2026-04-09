import SwiftUI

struct RootSwipeContainerView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.35), Color.purple.opacity(0.35), Color.black.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer(minLength: 24)
                if !store.isSettingsPageActive {
                    QuickAddView()
                }
                if store.isSettingsPageActive {
                    SettingsView()
                } else {
                    CategoryLaneView()
                }
                statsBar
                Spacer()
            }
            .padding()
        }
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .sheet(isPresented: $store.showTodaySheet) {
            TodayView()
        }
        .sheet(isPresented: $store.showArchiveSheet) {
            ArchiveSearchView()
        }
        .sheet(item: $store.selectedReminder) { reminder in
            ReminderDetailSheetView(reminder: reminder)
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.85), value: store.activeCategoryIndex)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 22)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                if abs(horizontal) > abs(vertical) {
                    if horizontal < -40 { store.cycleCategory(direction: 1) }
                    if horizontal > 40 { store.cycleCategory(direction: -1) }
                } else {
                    if vertical > 70 { store.showTodaySheet = true }
                    if vertical < -70 { store.showArchiveSheet = true }
                }
            }
    }

    private var statsBar: some View {
        let completedToday = store.reminders.filter { $0.status == .completed && Calendar.current.isDateInToday($0.createdAt) }.count
        let completedWeek = store.reminders.filter { $0.status == .completed && Calendar.current.isDate($0.createdAt, equalTo: .now, toGranularity: .weekOfYear) }.count

        return GlassCard {
            HStack {
                VStack(alignment: .leading) {
                    Text("Today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(completedToday) done")
                        .font(.headline)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(completedWeek) done")
                        .font(.headline)
                }
            }
        }
    }
}
