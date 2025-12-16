//
//  SettingsPage.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI
import SwiftData

struct SettingsPage: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ClassificationItem]
    
    let totalItems: Int
    @State private var hapticEnabled = true
    
    var averageConfidence: Double {
        guard !items.isEmpty else { return 0 }
        return items.reduce(0.0) { $0 + $1.confidence } / Double(items.count)
    }
    
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Statistics
                        statisticsSection
                        
                        // Camera Settings
                        cameraSection
                        
                        // App Info
                        appInfoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private var statisticsSection: some View {
        VStack(spacing: 12) {
            SectionHeader(icon: "chart.xyaxis.line", title: "Statistics")
            
            HStack(spacing: 12) {
                MetricCard(
                    icon: "photo.stack.fill",
                    title: "Total",
                    value: "\(items.count)",
                    color: Color(hex: "667eea")
                )
                
                MetricCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Avg Conf.",
                    value: String(format: "%.0f%%", averageConfidence * 100),
                    color: Color(hex: "38ef7d")
                )
            }
        }
    }
    
    private var cameraSection: some View {
        VStack(spacing: 12) {
            SectionHeader(icon: "camera.fill", title: "Preferences")
            
            VStack(spacing: 10) {
                SettingRow(
                    icon: "hand.tap.fill",
                    title: "Haptic Feedback",
                    subtitle: "Vibration on interactions",
                    isOn: $hapticEnabled
                )
            }
        }
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 12) {
            SectionHeader(icon: "info.circle.fill", title: "About")
            
            VStack(spacing: 10) {
                InfoRow(icon: "app.badge.fill", title: "Version", value: "2.0.0")
                InfoRow(icon: "cpu", title: "Model", value: "ResNet50")
                InfoRow(icon: "square.grid.3x3.fill", title: "Classes", value: "1,000")
                InfoRow(icon: "arrow.down.circle.fill", title: "Model Size", value: "102 MB")
            }
        }
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
        }
        .padding(.top, 8)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(ColorPalette.glassDark)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "667eea"))
        }
        .padding(14)
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

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(ColorPalette.glassDark)
                )
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(14)
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
