//
//  CameraManager.swift
//  CoreML-Vision
//
//  Created by Elmee on 15/12/2025.
//  Copyright © 2025 https://kamy.co. All rights reserved.
//

import AVFoundation
import Vision
import SwiftUI
import UIKit

@Observable
class CameraManager: NSObject {
    var topPrediction: String = "Point camera at an object"
    var confidence: Double = 0.0
    var topFivePredictions: [(String, Double)] = []
    var fps: Double = 0.0
    var inferenceTime: Double = 0.0
    var isAuthorized: Bool = false
    var showPermissionDenied: Bool = false
    var isFlashOn: Bool = false
    var capturedImage: UIImage?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoQueue = DispatchQueue(label: "com.coreml.vision.videoQueue")
    private var currentCamera: AVCaptureDevice?
    
    private var lastFrameTime: Date = Date()
    private var frameCount: Int = 0
    private var fpsUpdateTimer: Timer?
    
    // CoreML Model
    private var visionModel: VNCoreMLModel? = {
        do {
            let config = MLModelConfiguration()
            let model = try Resnet50(configuration: config)
            return try VNCoreMLModel(for: model.model)
        } catch {
            print("Failed to load CoreML model: \(error)")
            return nil
        }
    }()
    
    override init() {
        super.init()
        checkCameraAuthorization()
    }
    
    func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupCaptureSession()
                    } else {
                        self?.showPermissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDenied = true
        @unknown default:
            showPermissionDenied = true
        }
    }
    
    private func setupCaptureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        // Add camera input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              captureSession.canAddInput(input) else {
            print("Failed to setup camera input")
            captureSession.commitConfiguration()
            return
        }
        
        currentCamera = camera
        captureSession.addInput(input)
        
        // Add video output
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Add photo output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration()
        
        // Start FPS timer
        startFPSTimer()
    }
    
    func startSession() {
        guard !captureSession.isRunning else { return }
        videoQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        guard captureSession.isRunning else { return }
        videoQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    var session: AVCaptureSession {
        return captureSession
    }

    func toggleFlash() {
        guard let camera = currentCamera, camera.hasTorch else { return }
        
        do {
            try camera.lockForConfiguration()
            
            if isFlashOn {
                camera.torchMode = .off
                isFlashOn = false
            } else {
                if camera.isTorchModeSupported(.on) {
                    try camera.setTorchModeOn(level: 1.0)
                    isFlashOn = true
                }
            }
            
            camera.unlockForConfiguration()
            
            // Haptic feedback
            HapticManager.impact(.medium)
        } catch {
            print("Flash error: \(error)")
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        
        // Enable flash if needed
        if isFlashOn {
            settings.flashMode = .on
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        // Haptic feedback
        HapticManager.notification(.success)
    }
    
    private func startFPSTimer() {
        fpsUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.fps = Double(self.frameCount)
                self.frameCount = 0
            }
        }
    }
    
    private func performVisionRequest(on pixelBuffer: CVPixelBuffer) {
        guard let model = visionModel else { return }
        
        let startTime = Date()
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            
            let inferenceTime = Date().timeIntervalSince(startTime) * 1000 // Convert to ms
            
            if let error = error {
                print("Vision request error: \(error)")
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  !results.isEmpty else {
                return
            }
            
            // Get top prediction
            let topResult = results[0]
            
            // Get top 5 predictions
            let topFive = Array(results.prefix(5)).map { ($0.identifier, Double($0.confidence)) }
            
            // Haptic feedback for high confidence
            if topResult.confidence > 0.85 && self.topPrediction != topResult.identifier.capitalized {
                DispatchQueue.main.async {
                    HapticManager.impact(.light)
                }
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.topPrediction = topResult.identifier.capitalized
                self.confidence = Double(topResult.confidence)
                self.topFivePredictions = topFive
                self.inferenceTime = inferenceTime
            }
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([request])
        } catch {
            print("❌ Failed to perform request: \(error)")
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCount += 1
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        performVisionRequest(on: pixelBuffer)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}
