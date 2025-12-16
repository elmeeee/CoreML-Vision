//
//  ActionButton.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct ActionButton: View {
    let icon: String
    let label: String
    var badge: Int = 0
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.impact(.medium)
            action()
        }) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(isActive ? .yellow : .white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isActive ? Color.yellow.opacity(0.5) : ColorPalette.glassBorder,
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .shadow(color: isActive ? .yellow.opacity(0.3) : .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    if badge > 0 {
                        BadgeView(count: badge)
                            .offset(x: 6, y: -6)
                    }
                }
                
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
    }
}

struct CaptureButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.notification(.success)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        }) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 76, height: 76)
                    .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Inner circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white, Color(hex: "f5f5f5")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            }
        }
    }
}
