//
//  UITraitCollectionExtension.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

public extension UITraitCollection {
    
    var isAllRegular: Bool {
        return isAll(sizeClass: .regular)
    }
    
    var isAllCompact: Bool {
        return isAll(sizeClass: .compact)
    }
    
    var isAllUnspecified: Bool {
        return isAll(sizeClass: .unspecified)
    }
    
    func isAll(sizeClass: UIUserInterfaceSizeClass) -> Bool {
        return horizontalSizeClass == sizeClass && verticalSizeClass == sizeClass
    }
    
}
