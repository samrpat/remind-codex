import SwiftUI

struct RootSwipeContainerView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.35), Color.purple.opacity(0.35), Color.black.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                searchBar
                if !store.isSettingsPageActive {
                    QuickAddView()
                }
                if store.isSettingsPageActive {
                    SettingsView()
                } else {
                    CategoryLaneView()
                }
                todayWeekBar
                Spacer()
            }
            .padding()
        }
        .contentShape(Rectangle())
        .gesture(horizontalSwipeGesture)
        .sheet(isPresented: $store.showTodaySheet) {
            TodayView()
        }
        .sheet(isPresented: $store.showListDetailSheet) {
            ReminderListDetailView()
        }
        .sheet(item: $store.selectedReminder) { reminder in
            ReminderDetailSheetView(reminder: reminder)
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.85), value: store.activeCategoryIndex)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search reminders", text: $store.searchQuery)
                .textInputAutocapitalization(.never)
        }
        .padding(10)
        .integratedField()
    }

    private var horizontalSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 22)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                guard abs(horizontal) > abs(vertical) else { return }
                if horizontal < -40 { store.cycleCategory(direction: 1) }
                if horizontal > 40 { store.cycleCategory(direction: -1) }
            }
    }

    private var todayWeekBar: some View {
        GlassCard {
            HStack {
                Button {
                    store.todayScope = .today
                    store.showTodaySheet = true
                } label: {
                    metric(title: "Today", value: store.completionToday)
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    store.todayScope = .week
                    store.showTodaySheet = true
                } label: {
                    metric(title: "Week", value: store.completionWeek)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func metric(title: String, value: Int) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value) done")
                .font(.headline)
        }
    }
}
