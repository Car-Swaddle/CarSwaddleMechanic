//
//  UITraitCollectionExtension.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

public extension UITraitCollection {
    
    public var isAllRegular: Bool {
        return isAll(sizeClass: .regular)
    }
    
    public var isAllCompact: Bool {
        return isAll(sizeClass: .compact)
    }
    
    public var isAllUnspecified: Bool {
        return isAll(sizeClass: .unspecified)
    }
    
    public func isAll(sizeClass: UIUserInterfaceSizeClass) -> Bool {
        return horizontalSizeClass == sizeClass && verticalSizeClass == sizeClass
    }
    
}
