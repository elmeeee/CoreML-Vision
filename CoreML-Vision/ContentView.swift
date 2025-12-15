//
//  ContentView.swift
//  CoreML-Vision
//
//  Created by Elmee on 15/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var cameraManager = CameraManager()
    @State private var showTopFive = false
    @State private var showInfo = false
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var showCapturedPhoto = false
    
    // Snapshot of top 5 predictions - only updates when collapsed
    @State private var topFiveSnapshot: [(String, Double)] = []
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            if cameraManager.isAuthorized {
                // Camera feed (full screen)
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
                
                // Dark overlay for better text visibility
                LinearGradient(
                    colors: [
                        .black.opacity(0.4),
                        .clear,
                        .clear,
                        .black.opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // UI Overlay
                VStack(spacing: 0) {
                    // Top control bar
                    topControlBar
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // Bottom section with classification
                    bottomSection
                }
                
            } else if cameraManager.showPermissionDenied {
                permissionDeniedView
            } else {
                loadingView
            }
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .sheet(isPresented: $showInfo) {
            InfoSheetView()
        }
        .sheet(isPresented: $showHistory) {
            HistorySheetView(cameraManager: cameraManager)
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheetView(cameraManager: cameraManager)
        }
        .fullScreenCover(isPresented: $showCapturedPhoto) {
            if let image = cameraManager.capturedImage {
                CapturedPhotoView(
                    image: image,
                    label: cameraManager.topPrediction,
                    confidence: cameraManager.confidence,
                    isPresented: $showCapturedPhoto
                )
            }
        }
    }
    
    // MARK: - Top Control Bar
    private var topControlBar: some View {
        HStack(spacing: 16) {
            // Settings
            ControlButton(icon: "gearshape.fill") {
                showSettings = true
            }
            
            Spacer()
            
            // Metrics
            HStack(spacing: 12) {
                CompactMetric(
                    value: String(format: "%.0f", cameraManager.fps),
                    unit: "FPS",
                    color: fpsColor
                )
                
                CompactMetric(
                    value: String(format: "%.0f", cameraManager.inferenceTime),
                    unit: "ms",
                    color: inferenceColor
                )
            }
            
            Spacer()
            
            // Info
            ControlButton(icon: "info.circle.fill") {
                showInfo = true
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Bottom Section
    private var bottomSection: some View {
        VStack(spacing: 16) {
            // Classification result card
            classificationCard
                .padding(.horizontal, 20)
            
            // Control buttons
            HStack(spacing: 24) {
                // History
                ActionButton(
                    icon: "clock.arrow.circlepath",
                    label: "History",
                    badge: cameraManager.classificationHistory.count
                ) {
                    showHistory = true
                }
                
                // Capture button (center, larger)
                CaptureButton {
                    cameraManager.capturePhoto()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if cameraManager.capturedImage != nil {
                            showCapturedPhoto = true
                        }
                    }
                }
                
                // Flash toggle
                ActionButton(
                    icon: cameraManager.isFlashOn ? "bolt.fill" : "bolt.slash.fill",
                    label: "Flash",
                    isActive: cameraManager.isFlashOn
                ) {
                    cameraManager.toggleFlash()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Classification Card
    private var classificationCard: some View {
        VStack(spacing: 16) {
            // Main prediction
            VStack(spacing: 12) {
                Text(cameraManager.topPrediction)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Confidence
                HStack(spacing: 12) {
                    Text("\(Int(cameraManager.confidence * 100))%")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(confidenceColor)
                        .contentTransition(.numericText())
                    
                    Text("Confidence")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(confidenceColor.opacity(0.5), lineWidth: 2)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
            )
            
            // Top 5 toggle
            if !cameraManager.topFivePredictions.isEmpty {
                Button(action: {
                    // Capture snapshot when opening
                    if !showTopFive {
                        topFiveSnapshot = cameraManager.topFivePredictions
                    }
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showTopFive.toggle()
                    }
                }) {
                    HStack {
                        Text("Top 5 Predictions")
                            .font(.subheadline.weight(.semibold))
                        
                        Spacer()
                        
                        Image(systemName: showTopFive ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black.opacity(0.3))
                    )
                }
                
                // Top 5 list - uses snapshot to prevent glitching
                if showTopFive && !topFiveSnapshot.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(Array(topFiveSnapshot.enumerated()), id: \.element.0) { index, prediction in
                            PredictionRow(
                                rank: index + 1,
                                label: prediction.0,
                                confidence: prediction.1
                            )
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black.opacity(0.3))
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    // MARK: - Permission Denied View
    private var permissionDeniedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.5))
            
            Text("Camera Access Required")
                .font(.title2.bold())
                .foregroundStyle(.white)
            
            Text("Please enable camera access in Settings")
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Settings")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(.blue)
                    )
            }
        }
        .padding(40)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Initializing Camera...")
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    // MARK: - Computed Properties
    private var fpsColor: Color {
        if cameraManager.fps >= 25 { return .green }
        else if cameraManager.fps >= 15 { return .yellow }
        else { return .red }
    }
    
    private var inferenceColor: Color {
        if cameraManager.inferenceTime < 50 { return .green }
        else if cameraManager.inferenceTime < 100 { return .yellow }
        else { return .red }
    }
    
    private var confidenceColor: Color {
        if cameraManager.confidence >= 0.7 { return .green }
        else if cameraManager.confidence >= 0.4 { return .yellow }
        else { return .orange }
    }
}

// MARK: - Control Button
struct ControlButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.black.opacity(0.5))
                )
        }
    }
}

// MARK: - Compact Metric
struct CompactMetric: View {
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .contentTransition(.numericText())
            
            Text(unit)
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.black.opacity(0.5))
        )
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let label: String
    var badge: Int = 0
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(isActive ? .yellow : .white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(.black.opacity(0.5))
                        )
                    
                    if badge > 0 {
                        Text("\(badge)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Circle().fill(.red))
                            .offset(x: 4, y: -4)
                    }
                }
                
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Capture Button
struct CaptureButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(.white, lineWidth: 4)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .fill(.white)
                    .frame(width: 60, height: 60)
            }
        }
    }
}

// MARK: - Prediction Row
struct PredictionRow: View {
    let rank: Int
    let label: String
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 20)
            
            Text(label.capitalized)
                .font(.subheadline)
                .foregroundStyle(.white)
            
            Spacer()
            
            Text("\(Int(confidence * 100))%")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.1))
        )
    }
}

// MARK: - Captured Photo View
struct CapturedPhotoView: View {
    let image: UIImage
    let label: String
    let confidence: Double
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(.black.opacity(0.5)))
                    }
                    
                    Spacer()
                    
                    Button(action: sharePhoto) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(.black.opacity(0.5)))
                    }
                }
                .padding()
                
                Spacer()
                
                // Image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .padding()
                
                // Info
                VStack(spacing: 8) {
                    Text(label)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text("\(Int(confidence * 100))% Confidence")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding()
                
                Spacer()
            }
        }
    }
    
    private func sharePhoto() {
        let activityController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            if let popover = activityController.popoverPresentationController {
                popover.sourceView = rootViewController.view
                popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                           y: rootViewController.view.bounds.midY,
                                           width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootViewController.present(activityController, animated: true)
        }
    }
}

#Preview {
    ContentView()
}
