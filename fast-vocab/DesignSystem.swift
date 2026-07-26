import SwiftUI

enum AppColor {
    static let frontBeachBlue = Color(red: 63 / 255, green: 142 / 255, blue: 191 / 255)
    static let conPhungJade = Color(red: 45 / 255, green: 89 / 255, blue: 85 / 255)
    static let goldenSand = Color(red: 242 / 255, green: 196 / 255, blue: 141 / 255)
    static let coastalSunset = Color(red: 217 / 255, green: 140 / 255, blue: 95 / 255)
    static let marineMoss = Color(red: 35 / 255, green: 80 / 255, blue: 72 / 255)
    static let chalk = Color(red: 242 / 255, green: 228 / 255, blue: 216 / 255)
    static let card = Color.white
    static let textPrimary = Color(red: 47 / 255, green: 62 / 255, blue: 70 / 255)
    static let textSecondary = Color(red: 92 / 255, green: 116 / 255, blue: 128 / 255)
    static let border = Color(red: 214 / 255, green: 221 / 255, blue: 226 / 255)
}

struct CoastalBackground: View {
    var body: some View {
        AppColor.card
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

struct CoastalMark: View {
    var size: CGFloat = 72

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColor.frontBeachBlue.opacity(0.12))
            Image(systemName: "book.closed.fill")
                .font(.system(size: size * 0.43, weight: .semibold))
                .foregroundStyle(AppColor.frontBeachBlue)
            Image(systemName: "leaf.fill")
                .font(.system(size: size * 0.2))
                .foregroundStyle(AppColor.conPhungJade)
                .offset(x: size * 0.34, y: size * 0.26)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct SurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(AppColor.card.opacity(0.94), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.border.opacity(0.75), lineWidth: 1)
            }
            .shadow(color: AppColor.textPrimary.opacity(0.06), radius: 12, y: 5)
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(AppColor.frontBeachBlue.opacity(configuration.isPressed ? 0.78 : 1), in: RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct ProgressActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(AppColor.conPhungJade.opacity(configuration.isPressed ? 0.78 : 1), in: RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct AnswerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppColor.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(AppColor.card.opacity(configuration.isPressed ? 0.65 : 0.94), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(configuration.isPressed ? AppColor.frontBeachBlue : AppColor.border, lineWidth: 1)
            }
    }
}

extension View {
    func appSurface() -> some View {
        modifier(SurfaceModifier())
    }

    func appTypography() -> some View {
        foregroundStyle(AppColor.textPrimary)
            .fontDesign(.rounded)
    }
}