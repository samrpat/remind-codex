import SwiftUI

struct QuickAddView: View {
    @EnvironmentObject var store: ReminderStore
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 14) {
            Text(store.activeCategory?.name ?? "Quick Add")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("Type or speak: \"Take out trash tomorrow at 8pm\"", text: $store.quickInput, axis: .vertical)
                .lineLimit(1...3)
                .focused($focused)
                .font(.title3.weight(.semibold))
                .textFieldStyle(.plain)
                .submitLabel(.done)
                .onSubmit {
                    store.createReminderFromQuickInput()
                }

            HStack {
                Label("Swipe ← → categories", systemImage: "rectangle.3.group.bubble")
                Spacer()
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
}
