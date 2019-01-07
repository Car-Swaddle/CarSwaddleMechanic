//
//  UIRefreshControlExtension.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/30/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit


extension UIRefreshControl {
    
    func addRefreshTarget(target: Any?, action: Selector) {
        addTarget(target, action: action, for: .valueChanged)
    }
    
}
