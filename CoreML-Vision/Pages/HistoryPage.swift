//
//  HistoryPage.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct HistoryPage: View {
    @Environment(\.dismiss) var dismiss
    let cameraManager: CameraManager
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "0f0c29"), Color(hex: "302b63"), Color(hex: "24243e")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if cameraManager.classificationHistory.isEmpty {
                    emptyHistoryView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            // Stats header
                            statsHeader
                            
                            // History items
                            ForEach(cameraManager.classificationHistory) { item in
                                HistoryItemCard(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Classification History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Done")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(.white)
                    }
                }
                
                if !cameraManager.classificationHistory.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .alert("Clear History", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                cameraManager.clearHistory()
            }
        } message: {
            Text("Are you sure you want to clear all classification history?")
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 12) {
            StatBadge(
                icon: "photo.stack.fill",
                value: "\(cameraManager.classificationHistory.count)",
                label: "Items"
            )
            
            StatBadge(
                icon: "chart.line.uptrend.xyaxis",
                value: String(format: "%.0f%%", cameraManager.averageConfidence * 100),
                label: "Avg"
            )
        }
        .padding(.bottom, 8)
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea").opacity(0.2), Color(hex: "764ba2").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text("No History Yet")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
                Text("Captured photos will appear here")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
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

struct HistoryItemCard: View {
    let item: ClassificationHistoryItem
    
    var confidenceColor: Color {
        ColorPalette.confidenceColor(for: item.confidence)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(confidenceColor.opacity(0.3), lineWidth: 2)
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorPalette.glassDark)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(.white.opacity(0.3))
                    )
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(item.label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    // Confidence badge
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                        Text("\(Int(item.confidence * 100))%")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    }
                    .foregroundStyle(confidenceColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(confidenceColor.opacity(0.15))
                    )
                    
                    // Time
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text(item.timestamp, style: .relative)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorPalette.glassBorder, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
