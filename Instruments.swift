import SwiftUI

enum Sea {
    static let deep = Color(red: 0.038, green: 0.063, blue: 0.115)
    static let hull = Color(red: 0.066, green: 0.101, blue: 0.164)
    static let panel = Color(red: 0.097, green: 0.145, blue: 0.223)
    static let rim = Color(red: 0.19, green: 0.26, blue: 0.35)
    static let muted = Color(red: 0.64, green: 0.73, blue: 0.80)
    static let paper = Color(red: 0.94, green: 0.96, blue: 0.91)
    static let foam = Color(red: 0.42, green: 0.88, blue: 0.81)
    static let coral = Color(red: 1.0, green: 0.49, blue: 0.35)
    static let gold = Color(red: 1.0, green: 0.78, blue: 0.37)
}

struct Plate: View {
    let text: String
    var color: Color = Sea.muted
    init(_ text: String, _ color: Color = Sea.muted) { self.text = text; self.color = color }
    var body: some View {
        Text(verbatim: text.uppercased()).font(.system(.caption2, design: .monospaced, weight: .bold))
            .tracking(1.1).foregroundStyle(color)
    }
}

struct Display: View {
    let text: String
    var size: CGFloat
    @ScaledMetric(relativeTo: .title) private var scale: CGFloat = 1
    init(_ text: String, _ size: CGFloat) { self.text = text; self.size = size }
    var body: some View {
        Text(text).font(.system(size: size * scale, weight: .black).width(.condensed))
            .tracking(-size * 0.037).fixedSize(horizontal: false, vertical: true)
    }
}

struct Nori: View {
    @Environment(\.accessibilityReduceMotion) private var still
    @State private var drift = false
    private var motionDisabled: Bool {
        #if DEBUG && targetEnvironment(simulator)
        return still || CaptureLaunch.enabled
        #else
        return still
        #endif
    }
    var body: some View {
        Image("Nori").resizable().scaledToFit()
            .rotationEffect(.degrees(motionDisabled ? 0 : drift ? 2.5 : -2))
            .offset(y: motionDisabled ? 0 : drift ? -3 : 2)
            .onAppear { drift = true }
            .animation(motionDisabled ? nil : .easeInOut(duration: 1.9).repeatForever(autoreverses: true), value: drift)
            .accessibilityHidden(true)
    }
}

struct SonarMark: View {
    var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            let unit = side / 32
            context.scaleBy(x: unit, y: unit)
            for r in [12.0, 8, 4] {
                let box = CGRect(x: 16-r, y: 16-r, width: 2*r, height: 2*r)
                context.stroke(Path(ellipseIn: box), with: .color(Sea.foam), lineWidth: 1.7)
            }
            var sweep = Path()
            sweep.move(to: CGPoint(x: 16, y: 16))
            sweep.addLine(to: CGPoint(x: 27, y: 5))
            context.stroke(sweep, with: .color(Sea.paper), lineWidth: 2.1)
            context.fill(Path(ellipseIn: CGRect(x: 21, y: 8, width: 4, height: 4)), with: .color(Sea.coral))
        }.accessibilityHidden(true)
    }
}

struct ConsoleButton: View {
    let text: String
    let icon: String
    var enabled = true
    let action: () -> Void
    init(_ text: String, icon: String = "arrow.right", enabled: Bool = true, action: @escaping () -> Void) {
        self.text = text; self.icon = icon; self.enabled = enabled; self.action = action
    }
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text).font(.headline.bold())
                Spacer()
                Image(systemName: icon).font(.body.weight(.heavy))
            }.padding(.horizontal, 18).padding(.vertical, 14)
                .background(enabled ? Sea.coral : Sea.panel, in: RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(enabled ? Sea.deep : Sea.muted)
        }.buttonStyle(.plain).disabled(!enabled)
    }
}

struct SegmentMeter: View {
    let filled: Int
    var color = Sea.foam
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<10) { mark in
                RoundedRectangle(cornerRadius: 1.5).fill(mark < filled ? color : Sea.rim)
                    .frame(maxWidth: .infinity).frame(height: 5)
            }
        }.accessibilityHidden(true)
    }
}

extension View {
    func consolePlate(_ fill: Color = Sea.hull, radius: CGFloat = 14) -> some View {
        background(fill, in: RoundedRectangle(cornerRadius: radius))
            .overlay { RoundedRectangle(cornerRadius: radius).strokeBorder(Sea.rim, lineWidth: 1) }
    }
}
