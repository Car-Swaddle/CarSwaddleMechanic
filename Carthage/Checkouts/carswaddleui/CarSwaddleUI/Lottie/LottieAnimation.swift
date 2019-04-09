//
//  LottieAnimation.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 2/6/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Lottie
import Foundation

private let lottieAnimationFileType = "json"

public struct LottieAnimation {
    
    public var fileName: String
    
    public init(fileName: String) {
        self.fileName = fileName
    }
    
    /// Call this to get the animation view for the current enum
    ///
    /// - Returns: LOTAnimationView
    public func createAnimationView(bundle: Bundle = Bundle.main) -> Lottie.AnimationView {
        return AnimationView(filePath: self.path(bundle: bundle))
    }
    
    /// The path to the lottie animation in the main bundle.
    private func path(bundle: Bundle) -> String {
        guard let filePath = filePath(for: fileName, bundle: bundle) else {
            fatalError("You must have a file named \(fileName).json, in \(bundle).")
        }
        return filePath
    }
    
    private func filePath(for animationName: String, bundle: Bundle) -> String? {
        return bundle.path(forResource: animationName, ofType: lottieAnimationFileType)
    }
    
}
