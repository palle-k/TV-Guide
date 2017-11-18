//
//  TVChannelLogoClassifier.swift
//  TV Guide
//
//  Created by Palle Klewitz on 18.11.17.
//  Copyright © 2017 Technische Universität München. All rights reserved.
//

import Foundation
import QuartzCore
import CoreImage

class TVChannelLogoClassifier {
	init() {
		
	}
	
	func predictChannel(in image: CIImage) -> [String: Float] {
		return [:]
	}
	
	private func extractPossibleLogoAreas(in image: CIImage) -> [CIImage] {
		return []
	}
}
