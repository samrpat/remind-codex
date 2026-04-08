import SwiftUI

@main
struct RemindMeFasterApp: App {
    @StateObject private var store = ReminderStore()

    var body: some Scene {
        WindowGroup {
            RootSwipeContainerView()
                .environmentObject(store)
                .task {
                    await store.bootstrap()
                }
        }
    }
}
