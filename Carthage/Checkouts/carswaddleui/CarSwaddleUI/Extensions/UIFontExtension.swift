//
//  UIFontExtension.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

public extension UIFont {
    
    struct FontType: Equatable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static let system: FontType = FontType(rawValue: ".SFUIText")
        
        public static func ==(lhs: FontType, rhs: FontType) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    
    static func appFont(type: FontType, size: CGFloat, scaleFont: Bool = true) -> UIFont! {
        if scaleFont {
            let adjustedSize = UIFontMetrics.default.scaledValue(for: size)
            return UIFont(name: type.rawValue, size: adjustedSize)!
        } else {
            return UIFont(name: type.rawValue, size: size)!
        }
    }
    
    static func printAllFonts() {
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }
    
}

public extension UIFontDescriptor {
    var monospacedFontDescriptor: UIFontDescriptor {
        let fontDescriptorFeatureSettings = [[UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                                              UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector]]
        
        
        let fontDescriptorAttributes = [UIFontDescriptor.AttributeName.featureSettings: fontDescriptorFeatureSettings]
        let fontDescriptor = self.addingAttributes(fontDescriptorAttributes)
        return fontDescriptor
    }
}
