//
//  HorizontalSlideTransition.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 10/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit

public enum HorizontalSlideDirection {
    case right
    case left
}

public protocol HorizontalSlideTransitionDelegate: class {
    func relativeTransition(_ transition: HorizontalSlideTransition, fromViewController: UIViewController, toViewController: UIViewController) -> HorizontalSlideDirection
}

public class HorizontalSlideTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval = 0.2
    private let animationLength: CGFloat = 30.0
    private(set) public weak var delegate: HorizontalSlideTransitionDelegate?
    
    public init(delegate: HorizontalSlideTransitionDelegate) {
        self.delegate = delegate
    }
    
    @objc public func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    @objc public func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard let fromViewController = context.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = context.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromView = fromViewController.view,
            let toView = toViewController.view else { return }
        
        let duration = transitionDuration(using: context)
        let containerView = context.containerView
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        let offScreenRight = CGAffineTransform(translationX: animationLength, y: 0)
        let offScreenLeft = CGAffineTransform(translationX: -animationLength, y: 0)
        
        let direction = delegate?.relativeTransition(self, fromViewController: fromViewController, toViewController: toViewController) ?? .left
        
        switch direction {
        case .left:
            toView.transform = offScreenRight
        case .right:
            toView.transform = offScreenLeft
        }
        
        toView.alpha = 0.0
        
        UIView.animate(withDuration: duration, delay:0, options: [.curveEaseOut], animations: {
            switch direction {
            case .left:
                fromView.transform = offScreenLeft
            case .right:
                fromView.transform = offScreenRight
            }
            toView.transform = .identity
            
            fromView.alpha = 0.0
            toView.alpha = 1.0
        }, completion: { (finished: Bool) in
            context.completeTransition(finished)
            if finished {
                fromView.transform = .identity
                fromView.removeFromSuperview()
            }
        })
    }
    
}

