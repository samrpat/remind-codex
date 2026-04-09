import SwiftUI

struct QuickAddView: View {
    @EnvironmentObject var store: ReminderStore
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 14) {
            Text(store.activeCategory?.name ?? "Quick Add")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("Type or speak: \"pack clothes due 3pm tmrw\"", text: $store.quickInput, axis: .vertical)
                .lineLimit(1...3)
                .focused($focused)
                .font(.title3.weight(.semibold))
                .textFieldStyle(.plain)
                .submitLabel(.done)
                .onSubmit {
                    store.createReminderFromQuickInput()
                }

            quickPresetBar

            HStack {
                Label("Swipe ← → categories", systemImage: "rectangle.3.group.bubble")
                Spacer()
                if let due = store.quickPresetDueDate {
                    Text(due.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button {
                    store.createReminderFromQuickInput()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .onAppear {
            focused = true
        }
    }

    private var quickPresetBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([QuickDuePreset.inOneHour, .tonight, .tomorrowMorning, .tomorrowThreePM], id: \.self) { preset in
                    Button {
                        store.toggleQuickPreset(preset)
                    } label: {
                        Text(preset.label)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(store.selectedQuickPreset == preset ? Color.accentColor.opacity(0.25) : Color.white.opacity(0.09), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
