//
//  ClassificationCard.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct ClassificationCard: View {
    let topPrediction: String
    let confidence: Double
    let topFivePredictions: [(String, Double)]
    @Binding var showTopFive: Bool
    @Binding var topFiveSnapshot: [(String, Double)]
    
    var confidenceColor: Color {
        ColorPalette.confidenceColor(for: confidence)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Main prediction card
            mainPredictionCard
            
            // Top 5 toggle
            if !topFivePredictions.isEmpty {
                topFiveToggleButton
                
                // Top 5 list
                if showTopFive && !topFiveSnapshot.isEmpty {
                    topFiveList
                }
            }
        }
    }
    
    private var mainPredictionCard: some View {
        VStack(spacing: 16) {
            // Label
            Text(topPrediction)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .padding(.horizontal)
            
            // Confidence display
            VStack(spacing: 8) {
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(ColorPalette.glassDark, lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: confidence)
                        .stroke(
                            LinearGradient(
                                colors: [confidenceColor, confidenceColor.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: confidence)
                    
                    VStack(spacing: 4) {
                        Text("\(Int(confidence * 100))")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(confidenceColor)
                            .contentTransition(.numericText())
                        
                        Text("%")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                Text("Confidence")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [confidenceColor.opacity(0.5), confidenceColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: confidenceColor.opacity(0.3), radius: 20, x: 0, y: 10)
    }

    private var topFiveToggleButton: some View {
        Button(action: {
            if !showTopFive {
                topFiveSnapshot = topFivePredictions
            }
            
            HapticManager.impact(.light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showTopFive.toggle()
            }
        }) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.subheadline)
                
                Text("Top 5 Predictions")
                    .font(.system(size: 15, weight: .semibold))
                
                Spacer()
                
                Image(systemName: showTopFive ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.title3)
                    .rotationEffect(.degrees(showTopFive ? 0 : 0))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(ColorPalette.glassBorder, lineWidth: 1)
                    )
            )
        }
    }
 
    private var topFiveList: some View {
        VStack(spacing: 10) {
            ForEach(Array(topFiveSnapshot.enumerated()), id: \.element.0) { index, prediction in
                PredictionRow(
                    rank: index + 1,
                    label: prediction.0,
                    confidence: prediction.1
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorPalette.glassBorder, lineWidth: 1)
                )
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
