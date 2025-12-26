import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }

// MARK: - Cyberman Logo
}

private struct CybermanLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#0EA5E9"), Color(hex: "#7C3AED")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 2)
                )

            // Stylized "C" glyph
            Circle()
                .trim(from: 0.08, to: 0.82)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-20))
                .padding(26)

            // Inner accent
            Circle()
                .trim(from: 0.12, to: 0.3)
                .stroke(Color(hex: "#22D3EE"), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(40))
                .padding(26)
        }
        .shadow(color: Color(hex: "#22D3EE").opacity(0.35), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Progress Bar

private struct CybermanProgressBar: View {
    let progress: Double // 0...1

    var clamped: Double { max(0.0, min(1.0, progress)) }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.white.opacity(0.12))

                // Fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#22D3EE"), // cyan
                            Color(hex: "#6366F1"), // indigo
                            Color(hex: "#A855F7"), // purple
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: width * clamped)
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .animation(.easeInOut(duration: 0.25), value: clamped)
            }
        }
    }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct CybermanLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var angle: Double = 0
    @State private var glow: Bool = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Animated gradient background (updated palette)
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#0B0F1A"),
                        Color(hex: "#111827"),
                        Color(hex: "#0EA5E9"),
                        Color(hex: "#7C3AED"),
                        Color(hex: "#0B0F1A"),
                    ]),
                    center: .center,
                    angle: .degrees(angle)
                )
                .ignoresSafeArea()
                .animation(.linear(duration: 12).repeatForever(autoreverses: false), value: angle)
                .onAppear { angle = 360 }

                VStack(spacing: 28) {
                    // Logo
                    CybermanLogo()
                        .frame(width: min(geo.size.width, geo.size.height) * 0.28,
                               height: min(geo.size.width, geo.size.height) * 0.28)
                        .shadow(color: Color.white.opacity(glow ? 0.35 : 0.1), radius: glow ? 24 : 8)
                        .onAppear { glow = true }

                    // Loading text and percentage
                    VStack(spacing: 8) {
                        Text("Loading Resources")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 1)

                        Text("\(progressPercentage)%")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    // Progress bar
                    CybermanProgressBar(progress: progress)
                        .frame(width: min(geo.size.width, geo.size.height) * 0.66, height: 16)
                        .padding(.top, 8)
                }
            }
        }
    }
}

// MARK: - Фоновые представления

struct CybermanBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#0B0F1A"),
                Color(hex: "#0F172A"),
                Color(hex: "#111827"),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Circular Spinner

private struct CybermanCircularSpinner: View {
    let progress: Double
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 10)

            // Progress ring
            Circle()
                .trim(from: 0, to: max(0.02, min(1.0, progress)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#22D3EE"), // cyan
                            Color(hex: "#6366F1"), // indigo
                            Color(hex: "#A855F7"), // purple
                            Color(hex: "#F472B6"), // pink
                        ]),
                        center: .center,
                        angle: .degrees(rotation)
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Color(hex: "#22D3EE").opacity(0.35), radius: 8)
                .animation(.easeInOut(duration: 0.25), value: progress)

            // Rotating highlight arc
            Circle()
                .trim(from: 0.0, to: 0.12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.9), Color.clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(rotation))
                .rotationEffect(.degrees(-90))
                .blendMode(.screen)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Previews

#if canImport(SwiftUI)
import SwiftUI
#endif

// Use availability to keep using the modern #Preview API on iOS 17+ and provide a fallback for older versions
@available(iOS 17.0, *)
#Preview("Vertical") {
    CybermanLoadingOverlay(progress: 0.2)
}

@available(iOS 17.0, *)
#Preview("Horizontal", traits: .landscapeRight) {
    CybermanLoadingOverlay(progress: 0.2)
}

// Fallback previews for iOS < 17
struct CybermanLoadingOverlay_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CybermanLoadingOverlay(progress: 0.2)
                .previewDisplayName("Vertical (Legacy)")

            CybermanLoadingOverlay(progress: 0.2)
                .previewDisplayName("Horizontal (Legacy)")
                .previewLayout(.fixed(width: 812, height: 375)) // Simulate landscape on older previews
        }
    }
}
