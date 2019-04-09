//
//  UIViewControllerExtension.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 10/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func inNavigationController() -> UINavigationController {
        let nav = UINavigationController(rootViewController: self)
        nav.view.layer.shadowColor = UIColor.clear.cgColor
        nav.view.layer.shadowOpacity = 0.0
        nav.view.clipsToBounds = true
        return nav
    }
    
}

