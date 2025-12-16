//
//  BadgeView.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import SwiftUI

struct BadgeView: View {
    let count: Int
    
    var body: some View {
        if count > 0 {
            Text("\(count)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "f5576c"), Color(hex: "f093fb")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color(hex: "f5576c").opacity(0.5), radius: 4, x: 0, y: 2)
        }
    }
}
