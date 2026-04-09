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

            quickTimeControls

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

    private var quickTimeControls: some View {
        HStack(spacing: 10) {
            Button {
                store.adjustQuickDayOffset(by: -1)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.bordered)

            Text(store.quickDaySummary)
                .font(.caption.weight(.semibold))
                .frame(minWidth: 80)

            Button {
                store.adjustQuickDayOffset(by: 1)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.bordered)

            Spacer(minLength: 4)

            quickTimeButton(.nineAM)
            quickTimeButton(.threePM)
        }
    }

    private func quickTimeButton(_ preset: QuickTimePreset) -> some View {
        Button {
            store.toggleQuickTimePreset(preset)
        } label: {
            Text(preset.label)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(store.selectedQuickTimePreset == preset ? Color.accentColor.opacity(0.25) : Color.white.opacity(0.09), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
