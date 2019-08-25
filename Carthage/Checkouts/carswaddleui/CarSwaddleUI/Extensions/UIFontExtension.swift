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


public extension UIFont.FontType {
    
    static let regular: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Regular")
    static let extraBold: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-ExtraBold")
    static let boldItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-BoldItalic")
    static let black: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Black")
    static let medium: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Medium")
    static let bold: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Bold")
    static let light: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Light")
    static let semiBold: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-SemiBold")
    static let lightItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-LightItalic")
    static let extraLight: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-ExtraLight")
    static let extraLightItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-ExtraLightItalic")
    static let semiBoldItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-SemiBoldItalic")
    static let thinItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-ThinItalic")
    static let thin: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Thin")
    static let blackItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-BlackItalic")
    static let italic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Italic")
    static let mediumItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-MediumItalic")
    static let extraBoldItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-ExtraBoldItalic")
    static let monoSpaced: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Monospaced")
    
}

public extension UIFont {
    
    static let detail: UIFont = UIFont.appFont(type: .regular, size: 14)
    static let title: UIFont = UIFont.appFont(type: .regular, size: 17)
    static let large: UIFont = UIFont.appFont(type: .semiBold, size: 19)
    
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
