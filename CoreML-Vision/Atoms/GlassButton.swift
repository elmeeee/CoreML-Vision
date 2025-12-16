//
//  GlassButton.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct GlassButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 44
    var isActive: Bool = false
    
    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundStyle(isActive ? .yellow : .white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(ColorPalette.glassBorder, lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}
