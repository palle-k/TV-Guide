//
//  TVChannelLogoClassifier.swift
//  TV Guide
//
//  Created by Palle Klewitz on 18.11.17.
//  Copyright © 2017 Palle Klewitz. All rights reserved.
//

import Foundation
import QuartzCore
import CoreImage
import CoreML
import Vision
import UIKit

class TVChannelLogoClassifier {
	private let model = LogoClassifier()
	
	func predictTVChannelName(in image: CIImage) -> [String: Double] {
		let logoAreas = extractPossibleLogoAreas(in: image)
			.map(UIImage.init(ciImage:))
			.filter{$0.size == CGSize(width: 120, height: 68)}
			.flatMap{$0.toCVPixelBuffer()}
		
		return logoAreas.reduce(into: [:]) { fullPrediction, buffer in
			guard let prediction = try? model.prediction(image: buffer) else {
				return
			}
			for (key, value) in prediction.prediction {
				fullPrediction[key, default: 0] += value
			}
		}
	}
	
	private func extractPossibleLogoAreas(in image: CIImage) -> [CIImage] {
		let cropAreaSizeFraction: CGFloat = 6
		
		let bounds = [
			CGRect(
				x: image.extent.minX,
				y: image.extent.minY,
				width: image.extent.width / cropAreaSizeFraction,
				height: image.extent.height / cropAreaSizeFraction
			),
			CGRect(
				x: image.extent.minX + image.extent.width * (cropAreaSizeFraction - 1) / cropAreaSizeFraction,
				y: image.extent.minY,
				width: image.extent.width / cropAreaSizeFraction,
				height: image.extent.height / cropAreaSizeFraction
			),
			CGRect(
				x: image.extent.minX,
				y: image.extent.minY + image.extent.height * (cropAreaSizeFraction - 1) / cropAreaSizeFraction,
				width: image.extent.width / cropAreaSizeFraction,
				height: image.extent.height / cropAreaSizeFraction
			),
			CGRect(
				x: image.extent.minX + image.extent.width * (cropAreaSizeFraction - 1) / cropAreaSizeFraction,
				y: image.extent.minY + image.extent.height * (cropAreaSizeFraction - 1) / cropAreaSizeFraction,
				width: image.extent.width / cropAreaSizeFraction,
				height: image.extent.height / cropAreaSizeFraction
			)
		]
		return bounds.map(image.cropped(to:)).flatMap { image in
			return image.transformed(by: CGAffineTransform(scaleX: 120 / image.extent.width, y: 68 / image.extent.height))
		}
	}
}
