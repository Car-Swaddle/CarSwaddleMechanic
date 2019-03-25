//
//  LoadingButton.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 3/22/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

open class LoadingButton: UIButton {
    
    open var isLoading: Bool = false {
        didSet {
            guard oldValue != isLoading else { return }
            if isLoading {
                updateForIsLoading()
            } else {
                updateForIsNotLoading()
            }
            isEnabled = !isLoading
        }
    }
    
    open var indicatorViewStyle: UIActivityIndicatorView.Style = .gray {
        didSet {
            spinner.style = indicatorViewStyle
        }
    }
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: indicatorViewStyle)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isHidden = true
        return spinner
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.isHidden = isLoading
    }
    
    private func updateForIsLoading() {
        addSubview(spinner)
        spinner.constrainToCenter()
        spinner.startAnimating()
        spinner.isHidden = false
        spinner.alpha = 0.0
        
        UIView.animate(withDuration: 0.25) {
            self.spinner.alpha = 1.0
            self.titleLabel?.alpha = 0
        }
    }
    
    private func updateForIsNotLoading() {
        spinner.stopAnimating()
        UIView.animate(withDuration: 0.25, animations: {
            self.spinner.alpha = 0.0
            self.titleLabel?.alpha = 1.0
        }) { isFinished in
            self.spinner.isHidden = true
        }
    }
    
}

