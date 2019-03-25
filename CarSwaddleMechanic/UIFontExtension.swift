//
//  UIFontExtension.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/15/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

//public extension UIFont {
//
//    public struct FontType: Equatable {
//        public var rawValue: String
//
//        public static func ==(lhs: FontType, rhs: FontType) -> Bool {
//            return lhs.rawValue == rhs.rawValue
//        }
//    }
//
//    public static func appFont(type: FontType, size: CGFloat) -> UIFont! {
//        let adjustedSize = UIFontMetrics.default.scaledValue(for: size)
//        return UIFont(name: type.rawValue, size: adjustedSize)!
//    }
//
//    public static func printAllFonts() {
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }
//    }
//
//}
//
//extension UIFontDescriptor {
//    var monospacedDigitFontDescriptor: UIFontDescriptor {
//        let fontDescriptorFeatureSettings = [[UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
//                                              UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector]]
//
//
//        let fontDescriptorAttributes = [UIFontDescriptor.AttributeName.featureSettings: fontDescriptorFeatureSettings]
//        let fontDescriptor = self.addingAttributes(fontDescriptorAttributes)
//        return fontDescriptor
//    }
//}
