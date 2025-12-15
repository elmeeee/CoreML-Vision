//
//  SheetViews.swift
//  CoreML-Vision
//
//  Created by Elmee on 15/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct HistorySheetView: View {
    @Environment(\.dismiss) var dismiss
    let cameraManager: CameraManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if cameraManager.classificationHistory.isEmpty {
                    emptyHistoryView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(cameraManager.classificationHistory) { item in
                                HistoryCard(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                
                if !cameraManager.classificationHistory.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") {
                            cameraManager.clearHistory()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundStyle(.white.opacity(0.3))
            
            Text("No History")
                .font(.title3.bold())
                .foregroundStyle(.white)
            
            Text("Captured photos will appear here")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

// MARK: - History Card
struct HistoryCard: View {
    let item: ClassificationHistoryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.1))
                    .frame(width: 60, height: 60)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.label)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text("\(Int(item.confidence * 100))% • \(item.timestamp, style: .relative) ago")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Settings Sheet View
struct SettingsSheetView: View {
    @Environment(\.dismiss) var dismiss
    let cameraManager: CameraManager
    @State private var hapticEnabled = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    // Camera Section
                    Section {
                        Toggle(isOn: Binding(
                            get: { cameraManager.isFlashOn },
                            set: { _ in cameraManager.toggleFlash() }
                        )) {
                            Label("Flash", systemImage: "bolt.fill")
                        }
                    } header: {
                        Text("Camera")
                    }
                    
                    // Feedback Section
                    Section {
                        Toggle(isOn: $hapticEnabled) {
                            Label("Haptic Feedback", systemImage: "hand.tap.fill")
                        }
                    } header: {
                        Text("Feedback")
                    }
                    
                    // Stats Section
                    Section {
                        HStack {
                            Text("Total Classifications")
                            Spacer()
                            Text("\(cameraManager.totalClassifications)")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Average Confidence")
                            Spacer()
                            Text(String(format: "%.1f%%", cameraManager.averageConfidence * 100))
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("History Count")
                            Spacer()
                            Text("\(cameraManager.classificationHistory.count)")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("Statistics")
                    }
                    
                    // About Section
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("2.0.0")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Model")
                            Spacer()
                            Text("ResNet50")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Classes")
                            Spacer()
                            Text("1000")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("About")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Info Sheet View
struct InfoSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 50))
                                .foregroundStyle(.blue)
                            
                            Text("CoreML Vision")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                            
                            Text("Real-Time Image Classification")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        
                        Divider()
                            .background(.white.opacity(0.2))
                        
                        // Features
                        InfoSection(
                            title: "Features",
                            icon: "star.fill",
                            items: [
                                "Real-time classification at 30 FPS",
                                "Photo capture with sharing",
                                "Classification history",
                                "Performance statistics",
                                "On-device ML processing"
                            ]
                        )
                        
                        // Model
                        InfoSection(
                            title: "Model",
                            icon: "cpu",
                            items: [
                                "ResNet50 (50-layer CNN)",
                                "1000 ImageNet classes",
                                "~92% top-5 accuracy",
                                "102 MB model size"
                            ]
                        )
                        
                        // Privacy
                        InfoSection(
                            title: "Privacy",
                            icon: "lock.shield.fill",
                            items: [
                                "100% on-device processing",
                                "No data collection",
                                "No internet required",
                                "Your privacy is protected"
                            ]
                        )
                        
                        Divider()
                            .background(.white.opacity(0.2))
                        
                        // Footer
                        VStack(spacing: 8) {
                            Text("Version 2.0.0")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                            
                            Text("Built with SwiftUI • iOS 18+")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                            
                            Text("© 2025 Sufiandy Elmy")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Info Section
struct InfoSection: View {
    let title: String
    let icon: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundStyle(.blue)
                        Text(item)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .font(.subheadline)
                }
            }
        }
    }
}
