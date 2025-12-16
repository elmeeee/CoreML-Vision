//
//  HistoryPage.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI
import SwiftData

struct HistoryPage: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClassificationItem.timestamp, order: .reverse) private var items: [ClassificationItem]
    
    @State private var showDeleteConfirmation = false
    @State private var selectedItem: ClassificationItem?
    @State private var showImagePreview = false
    
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
                
                if items.isEmpty {
                    emptyHistoryView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            // Stats header
                            statsHeader
                            
                            // History items
                            ForEach(items) { item in
                                HistoryItemCard(item: item)
                                    .onTapGesture {
                                        selectedItem = item
                                        showImagePreview = true
                                    }
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
                
                if !items.isEmpty {
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
            .sheet(isPresented: $showImagePreview) {
                if let item = selectedItem {
                    ImagePreviewView(item: item, isPresented: $showImagePreview)
                }
            }
        }
        .alert("Clear History", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllHistory()
            }
        } message: {
            Text("Are you sure you want to clear all classification history?")
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 12) {
            StatBadge(
                icon: "photo.stack.fill",
                value: "\(items.count)",
                label: "Items"
            )
            
            StatBadge(
                icon: "chart.line.uptrend.xyaxis",
                value: String(format: "%.0f%%", averageConfidence * 100),
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
    
    private func clearAllHistory() {
        HapticManager.notification(.warning)
        for item in items {
            modelContext.delete(item)
        }
        try? modelContext.save()
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
    let item: ClassificationItem
    
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

// MARK: - Image Preview View
struct ImagePreviewView: View {
    let item: ClassificationItem
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirmation = false
    
    var confidenceColor: Color {
        ColorPalette.confidenceColor(for: item.confidence)
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
                    
                    HStack(spacing: 12) {
                        if let image = item.image {
                            GlassButton(icon: "square.and.arrow.up", action: {
                                shareImage(image)
                            }, size: 44)
                        }
                        
                        GlassButton(icon: "trash", action: {
                            showDeleteConfirmation = true
                        }, size: 44)
                    }
                }
                .padding()
                
                Spacer()
                
                // Image
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 20)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorPalette.glassDark)
                        .frame(height: 300)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white.opacity(0.3))
                                Text("No Image")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        )
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Info card
                VStack(spacing: 16) {
                    Text(item.label)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 20) {
                        // Confidence
                        VStack(spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text("\(Int(item.confidence * 100))%")
                                    .font(.title3.weight(.semibold))
                            }
                            .foregroundStyle(confidenceColor)
                            
                            Text("Confidence")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        Divider()
                            .frame(height: 40)
                            .background(.white.opacity(0.2))
                        
                        // Timestamp
                        VStack(spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.title3)
                                Text(item.timestamp, style: .time)
                                    .font(.title3.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            
                            Text(item.timestamp, style: .date)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
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
                                .stroke(confidenceColor.opacity(0.3), lineWidth: 2)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .alert("Delete Item", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("Are you sure you want to delete this classification?")
        }
    }
    
    private func shareImage(_ image: UIImage) {
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
    
    private func deleteItem() {
        HapticManager.notification(.warning)
        modelContext.delete(item)
        try? modelContext.save()
        isPresented = false
    }
}
