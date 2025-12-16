//
//  ColorPalette.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct ColorPalette {
    // Primary Colors
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let successGradient = LinearGradient(
        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Confidence Colors
    static func confidenceColor(for value: Double) -> Color {
        if value >= 0.7 { return Color(hex: "38ef7d") }
        else if value >= 0.4 { return Color(hex: "ffd93d") }
        else { return Color(hex: "ff6b6b") }
    }
    
    // Performance Colors
    static func fpsColor(for value: Double) -> Color {
        if value >= 25 { return Color(hex: "38ef7d") }
        else if value >= 15 { return Color(hex: "ffd93d") }
        else { return Color(hex: "ff6b6b") }
    }
    
    static func inferenceColor(for value: Double) -> Color {
        if value < 50 { return Color(hex: "38ef7d") }
        else if value < 100 { return Color(hex: "ffd93d") }
        else { return Color(hex: "ff6b6b") }
    }
    
    // Glass morphism
    static let glassDark = Color.white.opacity(0.1)
    static let glassLight = Color.white.opacity(0.05)
    static let glassBorder = Color.white.opacity(0.2)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
