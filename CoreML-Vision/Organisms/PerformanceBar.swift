//
//  PerformanceBar.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct PerformanceBar: View {
    let fps: Double
    let inferenceTime: Double
    
    var fpsColor: Color {
        ColorPalette.fpsColor(for: fps)
    }
    
    var inferenceColor: Color {
        ColorPalette.inferenceColor(for: inferenceTime)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            CompactMetricCard(
                value: String(format: "%.0f", fps),
                unit: "FPS",
                color: fpsColor,
                icon: "speedometer"
            )
            
            CompactMetricCard(
                value: String(format: "%.0f", inferenceTime),
                unit: "ms",
                color: inferenceColor,
                icon: "bolt.fill"
            )
        }
    }
}
