//
//  ContentView.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var historyItems: [ClassificationItem]
    
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
                
                // Enhanced gradient overlay
                LinearGradient(
                    colors: [
                        .black.opacity(0.5),
                        .clear,
                        .clear,
                        .black.opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // UI Overlay
                VStack(spacing: 0) {
                    // Top control bar
                    TopControlBar(
                        showSettings: $showSettings,
                        showInfo: $showInfo,
                        fps: cameraManager.fps,
                        inferenceTime: cameraManager.inferenceTime
                    )
                    
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
            InfoPage()
        }
        .sheet(isPresented: $showHistory) {
            HistoryPage()
        }
        .sheet(isPresented: $showSettings) {
            SettingsPage(totalItems: historyItems.count)
        }
        .fullScreenCover(isPresented: $showCapturedPhoto) {
            if let image = cameraManager.capturedImage {
                CapturedPhotoView(
                    image: image,
                    label: cameraManager.topPrediction,
                    confidence: cameraManager.confidence,
                    isPresented: $showCapturedPhoto,
                    onSave: { savedImage in
                        saveToHistory(image: savedImage)
                    }
                )
            }
        }
    }

    private var bottomSection: some View {
        VStack(spacing: 20) {
            // Classification result card
            ClassificationCard(
                topPrediction: cameraManager.topPrediction,
                confidence: cameraManager.confidence,
                topFivePredictions: cameraManager.topFivePredictions,
                showTopFive: $showTopFive,
                topFiveSnapshot: $topFiveSnapshot
            )
            .padding(.horizontal, 20)
            
            // Control buttons
            BottomControlBar(
                showHistory: $showHistory,
                historyCount: historyItems.count,
                isFlashOn: cameraManager.isFlashOn,
                onCapturePhoto: {
                    cameraManager.capturePhoto()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if cameraManager.capturedImage != nil {
                            showCapturedPhoto = true
                        }
                    }
                },
                onToggleFlash: {
                    cameraManager.toggleFlash()
                }
            )
        }
    }
    
    private var permissionDeniedView: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea").opacity(0.2), Color(hex: "764ba2").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("Camera Access Required")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                
                Text("Please enable camera access in Settings to use this app")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "gear")
                        .font(.headline)
                    Text("Open Settings")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 15, x: 0, y: 8)
            }
        }
        .padding(40)
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Initializing Camera...")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    private func saveToHistory(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let item = ClassificationItem(
            label: cameraManager.topPrediction,
            confidence: cameraManager.confidence,
            timestamp: Date(),
            imageData: imageData
        )
        
        modelContext.insert(item)
        try? modelContext.save()
        
        HapticManager.notification(.success)
    }
}

struct CapturedPhotoView: View {
    let image: UIImage
    let label: String
    let confidence: Double
    @Binding var isPresented: Bool
    let onSave: (UIImage) -> Void
    
    @State private var isSaved = false
    
    var confidenceColor: Color {
        ColorPalette.confidenceColor(for: confidence)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "0f0c29"), Color(hex: "302b63"), Color(hex: "24243e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    GlassButton(icon: "xmark", action: {
                        isPresented = false
                    }, size: 44)
                    
                    Spacer()
                    
                    GlassButton(icon: "square.and.arrow.up", action: {
                        sharePhoto()
                    }, size: 44)
                }
                .padding()
                
                Spacer()
                
                // Image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Info card
                VStack(spacing: 16) {
                    Text(label)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(confidenceColor)
                        
                        Text("\(Int(confidence * 100))% Confidence")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(confidenceColor)
                    }
                    
                    // Save button
                    Button(action: {
                        if !isSaved {
                            onSave(image)
                            isSaved = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down.fill")
                                .font(.headline)
                            Text(isSaved ? "Saved to History" : "Save to History")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(
                                    isSaved ?
                                    LinearGradient(
                                        colors: [Color(hex: "38ef7d"), Color(hex: "11998e")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: (isSaved ? Color(hex: "38ef7d") : Color(hex: "667eea")).opacity(0.5), radius: 15, x: 0, y: 8)
                    }
                    .disabled(isSaved)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(confidenceColor.opacity(0.3), lineWidth: 2)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func sharePhoto() {
        HapticManager.impact(.medium)
        
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
