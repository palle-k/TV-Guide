//
//  ViewController.swift
//  TV Guide
//
//  Created by Palle Klewitz on 17.11.17.
//  Copyright © 2017 Palle Klewitz. All rights reserved.
//

import UIKit
import AVFoundation

class ViewFinderViewController: UIViewController {

    private var session: AVCaptureSession?
    private var capturePreviewLayer: AVCaptureVideoPreviewLayer?
	private var shapeLayer: CAShapeLayer!
	
	private var rectangleExtractor = RectangleExtractor()
	private var logoClassifier = TVChannelLogoClassifier()
    
    @IBOutlet weak var instructionContainer: UIVisualEffectView!
	@IBOutlet weak var extractedRectangleImage: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
		instructionContainer.layer.cornerRadius = 10
        instructionContainer.clipsToBounds = true
		
		shapeLayer = CAShapeLayer()
		shapeLayer.frame = view.bounds
		shapeLayer.strokeColor = UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 0.5).cgColor
		shapeLayer.fillColor = UIColor.clear.cgColor
		shapeLayer.lineJoin = kCALineJoinRound
		shapeLayer.lineWidth = 10.0
		view.layer.addSublayer(shapeLayer)
        
        do {
            try self.initSession()
            session?.startRunning()
        } catch let error as NSError {
            let alert = UIAlertController(title: "Camera not available", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
	}
    
    @IBAction func unwindFromStationInfo(with segue: UIStoryboardSegue) {
        session?.startRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        session?.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        capturePreviewLayer?.frame = self.view.bounds
		shapeLayer?.frame = view.bounds
    }
    
    private func initSession() throws {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            throw NSError(domain: "com.tvguide.tvguide.capturesession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get capture device"])
        }
        let input = try AVCaptureDeviceInput(device: device)
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        let session = AVCaptureSession()
        session.sessionPreset = .hd1920x1080
        
        guard session.canAddInput(input) else {
            throw NSError(domain: "com.tvguide.tvguide.capturesession", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not add capture input"])
        }
        session.addInput(input)
        
        guard session.canAddOutput(output) else {
            throw NSError(domain: "com.tvguide.tvguide.capturesession", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not add video output"])
        }
        session.addOutput(output)
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.view.layer.insertSublayer(layer, at: 0)
        
        self.session = session
        self.capturePreviewLayer = layer
    }
	
	private var isProcessingImage = false
}

extension ViewFinderViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		guard !isProcessingImage else {
			return
		}
		isProcessingImage = true
		guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
			isProcessingImage = false
			return
		}
		let results = try! rectangleExtractor.update(buffer)
		isProcessingImage = false
		
		for (image, _) in results {
			let prediction = logoClassifier.predictTVChannelName(in: image)
			print(prediction.sorted(by: {$0.value < $1.value}).reversed().map{"\($0.key): \($0.value)"}.joined(separator: "\n") + "\n")
		}
		
		DispatchQueue.main.async {
			guard let (ciImage, bounds) = results.first else {
				self.extractedRectangleImage.image = nil
				self.shapeLayer.path = nil
				return
			}
			let context = CIContext()
			guard let image = context.createCGImage(ciImage, from: ciImage.extent) else {
				self.extractedRectangleImage.image = nil
				self.shapeLayer.path = nil
				return
			}
			guard 1.3 ... 2.0 ~= CGFloat(image.width) / CGFloat(image.height) else {
				self.extractedRectangleImage.image = nil
				self.shapeLayer.path = nil
				return
			}
			self.extractedRectangleImage.image = UIImage(cgImage: image)
			
			let path = CGMutablePath()
			path.addLines(between: bounds.map{CGPoint(x: $0.y * self.view.frame.width, y: $0.x * self.view.frame.height)})
			path.closeSubpath()
			self.shapeLayer?.path = path
		}
	}
}
