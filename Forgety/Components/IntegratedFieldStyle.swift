import SwiftUI

struct IntegratedFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
    }
}

extension View {
    func integratedField() -> some View {
        modifier(IntegratedFieldModifier())
    }
}
