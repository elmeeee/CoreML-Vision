//
//  PredictionRow.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct PredictionRow: View {
    let rank: Int
    let label: String
    let confidence: Double
    
    var confidenceColor: Color {
        ColorPalette.confidenceColor(for: confidence)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Rank badge
            Text("\(rank)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [confidenceColor.opacity(0.6), confidenceColor.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            // Label
            Text(label.capitalized)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(1)
            
            Spacer()
            
            // Confidence bar
            HStack(spacing: 8) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [confidenceColor, confidenceColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * confidence)
                    }
                }
                .frame(width: 60, height: 6)
                
                // Percentage
                Text("\(Int(confidence * 100))%")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(confidenceColor)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(confidenceColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
