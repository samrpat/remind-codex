import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Settings", systemImage: "gearshape.fill")
                    .font(.headline)

                Toggle("Smart parsing", isOn: $store.settings.smartParsingEnabled)
                Toggle("Voice quick add", isOn: $store.settings.voiceQuickAddEnabled)
                Toggle("Smart repeat alerts", isOn: $store.settings.smartRepeatEnabled)
                Toggle("Haptics", isOn: $store.settings.hapticsEnabled)
                Toggle("Badge count", isOn: $store.settings.showBadgeCount)

                Divider()

                Picker("Default priority", selection: $store.settings.defaultPriority) {
                    ForEach(Priority.allCases) { priority in
                        Text(priority.displayName).tag(priority)
                    }
                }

                Picker("Default repeat", selection: $store.settings.defaultRepeat) {
                    ForEach(RepeatFrequency.allCases) { frequency in
                        Text(frequency.displayName).tag(frequency)
                    }
                }

                TextField("Default list name", text: $store.settings.defaultListName)
                    .textFieldStyle(.roundedBorder)

                Toggle("iCloud sync", isOn: $store.settings.iCloudSyncEnabled)
                Toggle("Location triggers", isOn: $store.settings.locationTriggersEnabled)
                Toggle("WiFi triggers", isOn: $store.settings.wifiTriggersEnabled)
                Toggle("App mode triggers", isOn: $store.settings.appModeTriggersEnabled)
            }
        }
    }
}
