//
//  RectangleExtractor.swift
//  TV Guide
//
//  Created by Palle Klewitz on 17.11.17.
//  Copyright © 2017 Technische Universität München. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit
import AVFoundation
import Vision
import ImageIO

extension CGPoint {
	func scaled(to size: CGSize) -> CGPoint {
		return CGPoint(x: self.x * size.width, y: self.y * size.height)
	}
}
extension CGRect {
	func scaled(to size: CGSize) -> CGRect {
		return CGRect(
			x: self.origin.x * size.width,
			y: self.origin.y * size.height,
			width: self.size.width * size.width,
			height: self.size.height * size.height
		)
	}
}

extension CGImagePropertyOrientation {
	init(_ orientation: UIImageOrientation) {
		switch orientation {
		case .up: self = .up
		case .upMirrored: self = .upMirrored
		case .down: self = .down
		case .downMirrored: self = .downMirrored
		case .left: self = .left
		case .leftMirrored: self = .leftMirrored
		case .right: self = .right
		case .rightMirrored: self = .rightMirrored
		}
	}
}

class RectangleExtractor {
    func update(_ pixelBuffer: CVPixelBuffer) throws -> [[CGPoint]] {
		var rectangles: [VNRectangleObservation] = []
		
        let semaphore = DispatchSemaphore(value: 0)
        let request = VNDetectRectanglesRequest { (r, error) in
			defer {
				semaphore.signal()
			}
			
			guard let results = r.results as? [VNRectangleObservation], !results.isEmpty else {
				return
			}
			rectangles = results
        }
        request.maximumObservations = 1
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try handler.perform([request])
        semaphore.wait()
		
		let image = CIImage(cvImageBuffer: pixelBuffer)
		let imageSize = image.extent.size
		
		let images = rectangles.flatMap { observation -> CIImage? in
			// Verify detected rectangle is valid.
			let boundingBox = observation.boundingBox.scaled(to: imageSize)
			guard image.extent.contains(boundingBox) else {
				return nil
			}

			// Rectify the detected image
			let topLeft = observation.topLeft.scaled(to: imageSize)
			let topRight = observation.topRight.scaled(to: imageSize)
			let bottomLeft = observation.bottomLeft.scaled(to: imageSize)
			let bottomRight = observation.bottomRight.scaled(to: imageSize)
			let correctedImage = image
				.cropped(to: boundingBox)
				.applyingFilter(
					"CIPerspectiveCorrection", parameters: [
						"inputTopLeft": CIVector(cgPoint: topLeft),
						"inputTopRight": CIVector(cgPoint: topRight),
						"inputBottomLeft": CIVector(cgPoint: bottomLeft),
						"inputBottomRight": CIVector(cgPoint: bottomRight)
					]
				)
				.transformed(by: CGAffineTransform(rotationAngle: 3 * .pi / 2))
			return correctedImage
		}
		
		return rectangles.map { observation in
			return [observation.topLeft, observation.topRight, observation.bottomRight, observation.bottomLeft]
		}
    }
}
