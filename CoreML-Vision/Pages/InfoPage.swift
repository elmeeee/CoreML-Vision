//
//  InfoPage.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct InfoPage: View {
    @Environment(\.dismiss) var dismiss
    
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
                    VStack(spacing: 30) {
                        // Header
                        headerSection
                        
                        // Features
                        featureSection
                        
                        // Model Info
                        modelSection
                        
                        // Privacy
                        privacySection
                        
                        // Footer
                        footerSection
                    }
                    .padding()
                }
            }
            .navigationTitle("About")
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
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea").opacity(0.3), Color(hex: "764ba2").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 55, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text("CoreML Vision")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Real-Time Image Classification")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var featureSection: some View {
        VStack(spacing: 12) {
            SectionHeader(icon: "star.fill", title: "Features")
            
            VStack(spacing: 10) {
                FeatureRow(icon: "bolt.fill", title: "Real-time Classification", description: "30 FPS on-device processing")
                FeatureRow(icon: "camera.fill", title: "Photo Capture", description: "Save and share classifications")
                FeatureRow(icon: "clock.arrow.circlepath", title: "History Tracking", description: "Review past classifications")
                FeatureRow(icon: "chart.xyaxis.line", title: "Performance Stats", description: "Monitor FPS and inference time")
                FeatureRow(icon: "iphone", title: "On-Device ML", description: "No internet required")
            }
        }
    }
    
    private var modelSection: some View {
        VStack(spacing: 12) {
            SectionHeader(icon: "cpu", title: "Model Information")
            
            VStack(spacing: 10) {
                ModelInfoRow(title: "Architecture", value: "ResNet50", icon: "square.stack.3d.up.fill")
                ModelInfoRow(title: "Layers", value: "50-layer CNN", icon: "square.3.layers.3d")
                ModelInfoRow(title: "Classes", value: "1,000 ImageNet", icon: "square.grid.3x3.fill")
                ModelInfoRow(title: "Accuracy", value: "~92% top-5", icon: "checkmark.seal.fill")
                ModelInfoRow(title: "Size", value: "102 MB", icon: "arrow.down.circle.fill")
            }
        }
    }
    
    private var privacySection: some View {
        VStack(spacing: 12) {
            SectionHeader(icon: "lock.shield.fill", title: "Privacy & Security")
            
            VStack(spacing: 10) {
                PrivacyRow(icon: "checkmark.shield.fill", title: "100% On-Device", description: "All processing happens locally")
                PrivacyRow(icon: "xmark.circle.fill", title: "No Data Collection", description: "We don't collect any data")
                PrivacyRow(icon: "wifi.slash", title: "Works Offline", description: "No internet required")
                PrivacyRow(icon: "hand.raised.fill", title: "Privacy First", description: "Your data stays on your device")
            }
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Divider()
                .background(.white.opacity(0.2))
                .padding(.vertical, 10)
            
            VStack(spacing: 6) {
                Text("Version 2.0.0")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                
                Text("Built with SwiftUI • iOS 18+")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                
                Text("© 2025 Sufiandy Elmy")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.bottom, 20)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "38ef7d"), Color(hex: "11998e")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(hex: "38ef7d").opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
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

struct ModelInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
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
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
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

struct PrivacyRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(hex: "38ef7d"))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(hex: "38ef7d").opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
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
