//
//  ClassificationItem.swift
//  CoreML-Vision
//
//  Created by Elmee on 16/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import Foundation
import SwiftData
import UIKit

@Model
final class ClassificationItem {
    var id: UUID
    var label: String
    var confidence: Double
    var timestamp: Date
    @Attribute(.externalStorage) var imageData: Data?
    
    init(label: String, confidence: Double, timestamp: Date, imageData: Data?) {
        self.id = UUID()
        self.label = label
        self.confidence = confidence
        self.timestamp = timestamp
        self.imageData = imageData
    }
    
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
}
