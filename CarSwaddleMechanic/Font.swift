//
//  Font.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/22/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI


extension UIFont.FontType {
    
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
    
}

extension UIFont {
    
    static func monoSpacedAppFont(size: CGFloat) -> UIFont! {
        let adjustedSize = UIFontMetrics.default.scaledValue(for: size)
        let descriptor = UIFontDescriptor(name: "Montserrat", size: adjustedSize)
        return UIFont(descriptor: descriptor.monospacedFontDescriptor, size: 0)
    }
    
}

extension UIFont {
    
    public static let detailFontSize: CGFloat = 14
    public static let titleFontSize: CGFloat = 17
    public static let largeFontSize: CGFloat = 19
    
    public static let detailFontType: FontType = .regular
    public static let titleFontType: FontType = .regular
    public static let largeFontType: FontType = .semiBold
    
    public static let detail: UIFont = UIFont.appFont(type: detailFontType, size: detailFontSize)
    public static let title: UIFont = UIFont.appFont(type: titleFontType, size: titleFontSize)
    public static let large: UIFont = UIFont.appFont(type: largeFontType, size: largeFontSize)
    
}

extension UIColor {
    
    public static let largeTextColor: UIColor = .gray6
    public static let titleTextColor: UIColor = .gray6
    public static let detailTextColor: UIColor = .gray4
    public static let errorTextColor: UIColor = .appRed
    
    public static let selectionColor: UIColor = .appBlue
    
}


extension UILabel {
    
    public func detailStyled() {
        font = .detail
        textColor = .detailTextColor
    }
    
    public func titleStyled() {
        font = .title
        textColor = .titleTextColor
    }
    
    public func largeStyled() {
        font = .large
        textColor = .largeTextColor
    }
    
}

extension UIButton {
    
    public func detailStyled() {
        titleLabel?.detailStyled()
    }
    
    public func titleStyled() {
        titleLabel?.titleStyled()
    }
    
    public func largeStyled() {
        titleLabel?.largeStyled()
    }
    
}


extension UITextField {
    
    public func detailStyled() {
        font = .detail
        textColor = .detailTextColor
    }
    
    public func titleStyled() {
        font = .title
        textColor = .titleTextColor
    }
    
    public func largeStyled() {
        font = .large
        textColor = .largeTextColor
    }
    
}
