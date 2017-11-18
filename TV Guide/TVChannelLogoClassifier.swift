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

class TVChannelLogoClassifier {
	init() {
		
	}
	
	func predictTVChannelName(in image: CIImage) -> [String: Float] {
		let logoAreas = extractPossibleLogoAreas(in: image)
		return [:]
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
		return bounds.map(image.cropped(to:))
	}
}
