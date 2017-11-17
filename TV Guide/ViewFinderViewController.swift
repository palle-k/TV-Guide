//
//  ViewController.swift
//  TV Guide
//
//  Created by Palle Klewitz on 17.11.17.
//  Copyright © 2017 Technische Universität München. All rights reserved.
//

import UIKit
import AVFoundation

class ViewFinderViewController: UIViewController {

    private var session: AVCaptureSession?
    private var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
}

extension ViewFinderViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}
