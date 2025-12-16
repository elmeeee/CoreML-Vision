//
//  ControlBar.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct TopControlBar: View {
    @Binding var showSettings: Bool
    @Binding var showInfo: Bool
    let fps: Double
    let inferenceTime: Double
    
    var body: some View {
        HStack(spacing: 16) {
            GlassButton(icon: "gearshape.fill") {
                showSettings = true
            }
            
            Spacer()
            
            PerformanceBar(fps: fps, inferenceTime: inferenceTime)
            
            Spacer()
            
            GlassButton(icon: "info.circle.fill") {
                showInfo = true
            }
        }
        .padding(.horizontal, 20)
    }
}

struct BottomControlBar: View {
    @Binding var showHistory: Bool
    let historyCount: Int
    let isFlashOn: Bool
    let onCapturePhoto: () -> Void
    let onToggleFlash: () -> Void
    
    var body: some View {
        HStack(spacing: 32) {
            ActionButton(
                icon: "clock.arrow.circlepath",
                label: "History",
                badge: historyCount
            ) {
                showHistory = true
            }
            
            CaptureButton {
                onCapturePhoto()
            }
            
            ActionButton(
                icon: isFlashOn ? "bolt.fill" : "bolt.slash.fill",
                label: "Flash",
                isActive: isFlashOn
            ) {
                onToggleFlash()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
}
