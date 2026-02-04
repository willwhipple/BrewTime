//
//  Theme.swift
//  BrewTime
//
//  Design system: pastel palette (light/dark), 28pt cards, Material.ultraThin, rounded typography.
//

import SwiftUI

// MARK: - Semantic theme colors (resolve by color scheme)

enum Theme {
    static func background(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: 0x2C2520) : Color(hex: 0xF5E6CA)
    }

    static func accent1(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: 0x4A3C38) : Color(hex: 0xE7CCCC)
    }

    static func accent2(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: 0x3D4A3D) : Color(hex: 0xD4E2D4)
    }

    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: 0x3A322D) : Color.white.opacity(0.85)
    }

    static func primaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: 0xE8E0D8) : Color(hex: 0x3D3530)
    }

    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: 0xB0A69E) : Color(hex: 0x5C534C)
    }
}

// MARK: - Color hex extension

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

// MARK: - View modifiers

struct ThemeCardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(Theme.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 12, x: 0, y: 4)
    }
}

struct ThemeOverlayStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
    }
}

struct ThemeLargeTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 34, weight: .bold))
            .fontDesign(.rounded)
            .tracking(1.2)
    }
}

// MARK: - Convenience View extensions

extension View {
    func themeCard() -> some View {
        modifier(ThemeCardStyle())
    }

    func themeOverlay() -> some View {
        modifier(ThemeOverlayStyle())
    }

    func themeLargeTitle() -> some View {
        modifier(ThemeLargeTitleStyle())
    }
}

extension Text {
    func themeLargeTitle() -> some View {
        self
            .font(.system(size: 34, weight: .bold))
            .fontDesign(.rounded)
            .tracking(1.2)
    }
}
