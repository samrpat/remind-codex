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
                            .integratedField()
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Focus Mode Trigger")
                            .font(.headline)
                        themedToggle("Enable focus mode trigger", isOn: $store.settings.appModeTriggersEnabled)
                        if store.settings.appModeTriggersEnabled {
                            TextField("Focus mode name", text: $store.settings.preferredFocusMode)
                                .integratedField()
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
