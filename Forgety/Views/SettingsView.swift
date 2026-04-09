import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: ReminderStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Settings")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                GlassCard {
                    VStack(spacing: 10) {
                        themedToggle("Smart parsing", isOn: $store.settings.smartParsingEnabled)
                        themedToggle("Smart repeat alerts", isOn: $store.settings.smartRepeatEnabled)
                        themedToggle("Haptics", isOn: $store.settings.hapticsEnabled)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Defaults")
                            .font(.headline)
                        labeledPicker("Default priority", selection: $store.settings.defaultPriority, values: Priority.allCases) { $0.displayName }
                        labeledPicker("Default repeat", selection: $store.settings.defaultRepeat, values: RepeatFrequency.allCases) { $0.displayName }
                        TextField("Default list name", text: $store.settings.defaultListName)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Triggers")
                            .font(.headline)

                        themedToggle("Location triggers", isOn: $store.settings.locationTriggersEnabled)
                        if store.settings.locationTriggersEnabled {
                            Text("Radius: \(Int(store.settings.locationTriggerRadiusMeters))m")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Slider(value: $store.settings.locationTriggerRadiusMeters, in: 50...1000, step: 25)
                        }

                        themedToggle("WiFi triggers", isOn: $store.settings.wifiTriggersEnabled)
                        if store.settings.wifiTriggersEnabled {
                            TextField("Home WiFi SSID", text: $store.settings.homeSSID)
                                .textFieldStyle(.roundedBorder)
                            TextField("Work/School WiFi SSID", text: $store.settings.workSSID)
                                .textFieldStyle(.roundedBorder)
                        }

                        themedToggle("Focus mode triggers", isOn: $store.settings.appModeTriggersEnabled)
                        if store.settings.appModeTriggersEnabled {
                            TextField("Focus mode name", text: $store.settings.preferredFocusMode)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func themedToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.vertical, 2)
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
            .pickerStyle(.segmented)
        }
    }
}
