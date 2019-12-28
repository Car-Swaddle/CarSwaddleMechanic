//
//  SemanticFont.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/28/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

extension UIFont.FontType {
    
}

extension UIFont {
    
    public static let detailFontSize: CGFloat = 14
    public static let titleFontSize: CGFloat = 17
    public static let largeFontSize: CGFloat = 19
    public static let extraLargeFontSize: CGFloat = 22
    public static let actionFontSize: CGFloat = 17
    public static let headerFontSize: CGFloat = 12
    
    public static let detailFontType: FontType = .regular
    public static let titleFontType: FontType = .regular
    public static let largeFontType: FontType = .semiBold
    public static let extraLargeFontType: FontType = .semiBold
    public static let actionFontType: FontType = .bold
    public static let headerFontType: FontType = .semiBold
    
    public static let detail: UIFont = UIFont.appFont(type: detailFontType, size: detailFontSize)
    public static let title: UIFont = UIFont.appFont(type: titleFontType, size: titleFontSize)
    public static let large: UIFont = UIFont.appFont(type: largeFontType, size: largeFontSize)
    public static let action: UIFont = UIFont.appFont(type: actionFontType, size: actionFontSize)
    public static let extralarge: UIFont = UIFont.appFont(type: extraLargeFontType, size: extraLargeFontSize)
    public static let header: UIFont = UIFont.appFont(type: headerFontType, size: headerFontSize)
    
}

extension UIColor {
    
    // If any of these colors change, also change largeTextColor in the color assets
    
    
    public static var largeTextColor: UIColor = UIColor(named: "largeTextColor")! // gray 6
    public static let titleTextColor: UIColor = UIColor(named: "titleTextColor")! // gray 6
    public static let detailTextColor: UIColor = UIColor(named: "detailTextColor")! // gray 4
    public static let errorTextColor: UIColor = UIColor(named: "errorTextColor")!
    
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

