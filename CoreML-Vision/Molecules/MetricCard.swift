//
//  MetricCard.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    var subtitle: String? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            // Value
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(color)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.5), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct CompactMetricCard: View {
    let value: String
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
            
            HStack(spacing: 3) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText())
                
                Text(unit)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(color)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}
