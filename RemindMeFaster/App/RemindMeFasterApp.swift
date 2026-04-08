import SwiftUI

/// Root app shell for embedding in an existing app target.
///
/// Note: This type intentionally does not use `@main` so it can be dropped into
/// projects that already have an app entry point (for example, `ForgetyApp`).
struct RemindMeFasterAppView: View {
    @StateObject private var store = ReminderStore()

    var body: some View {
        RootSwipeContainerView()
            .environmentObject(store)
            .task {
                await store.bootstrap()
            }
    }
}
