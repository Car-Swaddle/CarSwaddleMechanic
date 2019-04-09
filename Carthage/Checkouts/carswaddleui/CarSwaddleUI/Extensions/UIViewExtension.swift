//
//  UIViewExtension.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 10/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit


private let SpinAnimationKey = "spinAnimation"

/**
 Used to determine a side. Currently used in determining the side on which to add a hariline view.
 
 - seealso: `addHairlineView(...)`
 */
public enum Side {
    case top
    case bottom
    case left
    case right
}

public extension Side {
    
    /// `NSLayoutAttribute` for the corresponding `Side`.
    var layoutAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .top: return NSLayoutConstraint.Attribute.top
        case .bottom: return NSLayoutConstraint.Attribute.bottom
        case .left: return NSLayoutConstraint.Attribute.left
        case .right: return NSLayoutConstraint.Attribute.right
        }
    }
    
    /// `NSLayoutAttribute` for the corresponding height or width attribute.
    var sizeAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .top, .bottom: return NSLayoutConstraint.Attribute.height
        case .left, .right: return NSLayoutConstraint.Attribute.width
        }
    }
}


public extension UIView {
    
    /// Since stack views are jacked on hiding/showing views, use this to show/hide a
    /// view in a stack view. This will only set the `hidden` property if it isn't already
    /// the value given. Stackviews are bugged where if you hide a view twice, you'll
    /// need to unhide it twice for it to show... 😩🔫
    // http://www.openradar.me/22819594
    // http://stackoverflow.com/questions/33240635/hidden-property-cannot-be-changed-within-an-animation-block
    var isHiddenInStackView: Bool {
        get {
            return isHidden
        }
        set {
            if isHidden != newValue {
                isHidden = newValue
            }
        }
    }
    
    /**
     Adds layout constraints constraining the sender to it's parent view. The sender must have a superview or it will return nil.
     
     - parameter insets: `UIEdgeInsets` Each side will be inset by the given insets. Defaults to `UIEdgeInsetsZero`.
     
     - returns: `(top:NSLayoutConstraint, bottom:NSLayoutConstraint, left:NSLayoutConstraint, right:NSLayoutConstraint)` All added constraints.
     */
    @discardableResult func pinFrameToSuperViewBounds(insets: UIEdgeInsets = UIEdgeInsets.zero, useSafeArea: Bool = false) -> (top:NSLayoutConstraint, bottom:NSLayoutConstraint, left:NSLayoutConstraint, right:NSLayoutConstraint)? {
        assert(self.superview != nil, "Invalid superview!!!")
        guard let superview = superview else { return nil }
        translatesAutoresizingMaskIntoConstraints = false // TODO: Look into taking this out. But Don't know what it would effect.
        
        let top: NSLayoutConstraint
        let bottom: NSLayoutConstraint
        let left: NSLayoutConstraint
        let right: NSLayoutConstraint
        
        if useSafeArea {
            top = topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: insets.top)
            bottom = bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
            left = leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: insets.left)
            right = trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right)
            
            NSLayoutConstraint.activate([top, bottom, left, right])
        } else {
            top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1.0, constant: insets.top)
            bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1.0, constant: -insets.bottom)
            left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: superview, attribute: .left, multiplier: 1.0, constant: insets.left)
            right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: superview, attribute: .right, multiplier: 1.0, constant: -insets.right)
            
            
            superview.addConstraint(top)
            superview.addConstraint(bottom)
            superview.addConstraint(left)
            superview.addConstraint(right)
        }
        
        return (top, bottom, left, right)
    }
    
    /**
     Constrains the sender to the given sides of the senders superview.
     
     - parameter sides: `[Side]` Sides to constrain to superview. Do not add the same side twice.
     
     - returns: `[NSLayoutConstraint]?` Constraints added to the sender.
     
     */
    @discardableResult func constrain(toSides sides: [Side]) -> [NSLayoutConstraint]? {
        assert(self.superview != nil, "Invalid superview!!!")
        guard let superview = superview else { return nil }
        
        var constraints: [NSLayoutConstraint]? = nil
        for side in sides {
            if constraints == nil { constraints = [NSLayoutConstraint]() }
            let constraint = NSLayoutConstraint(item: self, attribute: side.layoutAttribute, relatedBy: .equal, toItem: superview, attribute: side.layoutAttribute, multiplier: 1.0, constant: 0.0)
            superview.addConstraint(constraint)
            constraints?.append(constraint)
        }
        
        return constraints
    }
    
    /**
     Constrain the view to be centered in in its superview
     
     The view must already be in the view hierarchy (i.e. have a superview)
     */
    func constrainToCenter() {
        guard let superview = superview else {
            assert(false, "Invalid superview!!!")
            return
        }
        centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
    }
    
    func constrainWithinEdges(insets: UIEdgeInsets = UIEdgeInsets.zero) {
        guard let superview = superview else {
            assert(false, "Invalid superview!!!")
            return
        }
        topAnchor.constraint(lessThanOrEqualTo: superview.topAnchor, constant: insets.top).isActive = true
        bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor, constant: insets.bottom).isActive = true
        leadingAnchor.constraint(lessThanOrEqualTo: superview.leadingAnchor, constant: insets.left).isActive = true
        trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: insets.right).isActive = true
    }
    
    @discardableResult func constraintsWithItem(_ item:AnyObject)->[NSLayoutConstraint] {
        return self.constraints.filter({ (constraint) -> Bool in
            return constraint.firstItem === item || constraint.secondItem === item
        })
    }
    
    func removeConstraintsWithItem(_ item: AnyObject) {
        self.removeConstraints(constraintsWithItem(item))
    }
    
    #if os(iOS)
    /**
     Should be called from a view controllers self.view
     
     - parameters:
     - notification: *NSNotification* The notification that the keyboard's height was changed
     
     - returns: *CGFloat* Height of Keyboard
     
     */
    @discardableResult func keyboardHeightFromBottomWithNotification(_ notification: Foundation.Notification) -> CGFloat {
        guard let userInfo = notification.userInfo as? [String:Any] else { return 0 }
        guard let rectValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return 0 }
        
        guard let window = self.window else {
            // If no window, use UIScreen. May be innaccurate for iPad, but since we only care about height, it is more accurate than not having this.
            let convertedFrame = self.convert(rectValue.cgRectValue, from: UIScreen.main.coordinateSpace)
            return convertedFrame.intersection(self.bounds).height
        }
        
        let convertedFrame = self.convert(rectValue.cgRectValue, from: window)
        return convertedFrame.intersection(self.bounds).height
    }
    #endif
    
    /**
     Add's a hariline view to the side desired.
     
     - parameter side: `Side` Side on which to put the hairline.
     - parameter color: `UIColor` Color of the hariline view.
     
     - seealso: `Side`
     
     */
    @discardableResult
    func addHairlineView(toSide side: Side, color: UIColor = .gray, size: CGFloat = 1.0 / UIScreen.main.scale, insets: UIEdgeInsets = .zero) -> UIView {
        let hairlineView = UIView()
        hairlineView.translatesAutoresizingMaskIntoConstraints = false
        hairlineView.backgroundColor = color
        addSubview(hairlineView)
        
        switch side {
        case .top:
            hairlineView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
        case .bottom:
            hairlineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom).isActive = true
        case .left:
            hairlineView.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left).isActive = true
        case .right:
            hairlineView.rightAnchor.constraint(equalTo: rightAnchor, constant: insets.right).isActive = true
        }
        
        switch side {
        case .top, .bottom:
            hairlineView.heightAnchor.constraint(equalToConstant: size).isActive = true
            hairlineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left).isActive = true
            hairlineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right).isActive = true
        case .left, .right:
            hairlineView.widthAnchor.constraint(equalToConstant: size).isActive = true
            hairlineView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
            hairlineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom).isActive = true
        }
        
        return hairlineView
    }
    
    /// Process this view and create a `UIImage` from it.
    func snapshotImage() -> UIImage? {
        assert(Thread.isMainThread, "Must be ran on the main thread!")
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        assert(snapshotImage != nil, "snapshot image should not be nil")
        UIGraphicsEndImageContext()
        
        return snapshotImage
    }
    
    
    // MARK: View Animations
    
    /// Spin the view for a certain `duration` with a number of `rotation`. Set `repeat` to `Float.infinity` to
    ///  spin forever.
    func spin(forDuration duration: CGFloat, numberOfRotations rotation: CGFloat, repeatCount: Float, clockwise: Bool = true) {
        guard layer.animation(forKey: SpinAnimationKey) == nil else { return }
        
        let spinAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        spinAnimation.toValue = .pi * 2.0 * rotation * duration * (clockwise ? 1.0 : -1.0)
        spinAnimation.duration = CFTimeInterval(duration)
        spinAnimation.isCumulative = true
        spinAnimation.repeatCount = repeatCount
        
        layer.add(spinAnimation, forKey: SpinAnimationKey)
    }
    
    /// Stop the view from spinning (from calling `spin`).
    func stopSpin() {
        layer.removeAnimation(forKey: SpinAnimationKey)
    }
    
    /// Shake the view with a custom animation.
    func shake(completion: @escaping (_ completed: Bool) -> () = { _ in } ) {
        transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [.allowUserInteraction, .curveEaseInOut], animations: { [weak self] in
            self?.transform = CGAffineTransform.identity
            }, completion: completion)
    }
    
    /// This will return the smallest possible length that will be displayed
    /// Used often with layer border widths.
    static var hairlineLength: CGFloat {
        return 1.0 / UIScreen.main.scale
    }
    
}

