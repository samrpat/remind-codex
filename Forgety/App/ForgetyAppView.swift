import SwiftUI

@main
struct ForgetyApp: App {
    var body: some Scene {
        WindowGroup {
            ForgetyAppView()
        }
    }
}

/// Root app shell with the swipe-first reminder experience.
struct ForgetyAppView: View {
    @StateObject private var store = ReminderStore()

    var body: some View {
        RootSwipeContainerView()
            .environmentObject(store)
            .task {
                await store.bootstrap()
            }
    }
}
