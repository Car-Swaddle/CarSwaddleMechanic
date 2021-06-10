//
//  SemanticFont.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/28/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

extension UIFont {
    
    public static let textSize: CGFloat = 15
    public static let textType: FontType = .semiBold
    public static let text: UIFont = UIFont.appFont(type: textType, size: textSize)
    
    public static let textEmphasizedSize: CGFloat = 15
    public static let textEmphasizedType: FontType = .semiBold
    public static let textEmphasized: UIFont = UIFont.appFont(type: textEmphasizedType, size: textEmphasizedSize)
    
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


extension UILabel {
    
    public func textEmphasizedStyled() {
        font = .textEmphasized
        textColor = .text
    }
    
    public func textStyled() {
        font = .text
        textColor = .text
    }
    
    public func detailStyled() {
        font = .detail
        textColor = .text
    }
    
    public func titleStyled() {
        font = .title
        textColor = .text
    }
    
    public func largeStyled() {
        font = .large
        textColor = .text
    }
    
}

extension UIButton {
    
    public func textEmphasizedStyled() {
        titleLabel?.textEmphasizedStyled()
    }
    
    public func textStyled() {
        titleLabel?.textStyled()
    }
    
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
    
    public func textStyled() {
        font = .text
        textColor = .text
    }
    
    public func textEmphasizedStyled() {
        font = .textEmphasized
        textColor = .text
    }
    
    public func detailStyled() {
        font = .detail
        textColor = .text
    }
    
    public func titleStyled() {
        font = .title
        textColor = .text
    }
    
    public func largeStyled() {
        font = .large
        textColor = .text
    }
    
}

