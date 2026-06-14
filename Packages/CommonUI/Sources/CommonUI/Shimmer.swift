import SwiftUI

public struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1

    public func body(content: Content) -> some View {
        content
            .overlay(gradient.mask(content))
            .onAppear {
                withAnimation(.linear(duration: 1.25).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }

    private var gradient: some View {
        GeometryReader { proxy in
            LinearGradient(
                gradient: Gradient(colors: [.clear, Color.white.opacity(0.55), .clear]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: proxy.size.width * phase)
        }
    }
}

public extension View {

    func shimmering() -> some View {
        modifier(Shimmer())
    }
}
