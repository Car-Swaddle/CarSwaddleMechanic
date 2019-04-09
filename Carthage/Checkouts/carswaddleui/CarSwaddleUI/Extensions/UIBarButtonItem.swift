//
//  UIBarButtonItem.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 11/3/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

public extension UIBarButtonItem {
    
    static func activityBarButtonItem(with style: UIActivityIndicatorView.Style) -> UIBarButtonItem {
        let activityButton = UIActivityIndicatorView(style: style)
        activityButton.startAnimating()
        return UIBarButtonItem(customView: activityButton)
    }
    
}
