//
//  ClassificationHistoryItem.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Foundation
import UIKit

struct ClassificationHistoryItem: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double
    let timestamp: Date
    let image: UIImage?
}
