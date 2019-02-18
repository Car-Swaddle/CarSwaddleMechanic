//
//  UIFontExtension.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/15/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

public extension UIFont {
    
    public enum FontType: String, CaseIterable {
        case regular = "Montserrat-Regular"
        case extraBold = "Montserrat-ExtraBold"
        case boldItalic = "Montserrat-BoldItalic"
        case black = "Montserrat-Black"
        case medium = "Montserrat-Medium"
        case bold = "Montserrat-Bold"
        case light = "Montserrat-Light"
        case semiBold = "Montserrat-SemiBold"
        case lightItalic = "Montserrat-LightItalic"
        case extraLight = "Montserrat-ExtraLight"
        case extraLightItalic = "Montserrat-ExtraLightItalic"
        case semiBoldItalic = "Montserrat-SemiBoldItalic"
        case thinItalic = "Montserrat-ThinItalic"
        case thin = "Montserrat-Thin"
        case blackItalic = "Montserrat-BlackItalic"
        case italic = "Montserrat-Italic"
        case mediumItalic = "Montserrat-MediumItalic"
        case extraBoldItalic = "Montserrat-ExtraBoldItalic"
    }
    
    public static func appFont(type: FontType, size: CGFloat) -> UIFont! {
        return UIFont(name: type.rawValue, size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    public static func printAllFonts() {
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }
    
}
