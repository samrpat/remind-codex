import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Settings", systemImage: "gearshape.fill")
                    .font(.headline)

                Toggle("Smart parsing", isOn: $store.settings.smartParsingEnabled)
                Toggle("Smart repeat alerts", isOn: $store.settings.smartRepeatEnabled)
                Toggle("Haptics", isOn: $store.settings.hapticsEnabled)

                Divider()

                Group {
                    labeledPicker("Default priority", selection: $store.settings.defaultPriority, values: Priority.allCases) { $0.displayName }
                    labeledPicker("Default repeat", selection: $store.settings.defaultRepeat, values: RepeatFrequency.allCases) { $0.displayName }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Default list name")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Reminders", text: $store.settings.defaultListName)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Divider()

                Toggle("Enable location triggers", isOn: $store.settings.locationTriggersEnabled)
                if store.settings.locationTriggersEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location trigger radius (meters)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Slider(value: $store.settings.locationTriggerRadiusMeters, in: 50...1000, step: 25)
                        Text("\(Int(store.settings.locationTriggerRadiusMeters)) m")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle("Enable WiFi triggers", isOn: $store.settings.wifiTriggersEnabled)
                if store.settings.wifiTriggersEnabled {
                    TextField("Home WiFi SSID", text: $store.settings.homeSSID)
                        .textFieldStyle(.roundedBorder)
                    TextField("Work/School WiFi SSID", text: $store.settings.workSSID)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle("Enable focus mode triggers", isOn: $store.settings.appModeTriggersEnabled)
                if store.settings.appModeTriggersEnabled {
                    TextField("Focus mode name (e.g. Work)", text: $store.settings.preferredFocusMode)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }

    private func labeledPicker<T: Hashable & Identifiable>(
        _ title: String,
        selection: Binding<T>,
        values: [T],
        label: @escaping (T) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker(title, selection: selection) {
                ForEach(values) { value in
                    Text(label(value)).tag(value)
                }
            }
            .labelsHidden()
        }
    }
}
