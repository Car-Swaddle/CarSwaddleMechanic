import UIKit

extension TranslucentAnimatedTransition {
    
    /// Options for animating the Translucency of to and from ViewControllers.
    public struct AnimationOptions {
        
        /// The alpha of the toViewController before the animation starts
        let beginToAlpha: CGFloat
        /// The alpha of the toViewController after the animation ends
        let endToAlpha: CGFloat
        /// The alpha of the endViewController before the animation starts
        let beginFromAlpha: CGFloat
        /// The alpha of the endViewController after the animation ends
        let endFromAlpha: CGFloat
        
        /// A default options for animating over the toViewController with the fromViewController sitting in front
        public static let overPresent = AnimationOptions(beginToAlpha: 0.0, endToAlpha: 1.0, beginFromAlpha: 1.0, endFromAlpha: 1.0)
        public static let overDismiss = AnimationOptions(beginToAlpha: 1.0, endToAlpha: 1.0, beginFromAlpha: 1.0, endFromAlpha: 0.0)
        /// A default options for a fading transition
        public static let replacePresent = AnimationOptions(beginToAlpha: 0.0, endToAlpha: 1.0, beginFromAlpha: 1.0, endFromAlpha: 0.0)
        public static let replaceDismiss = AnimationOptions(beginToAlpha: 1.0, endToAlpha: 0.0, beginFromAlpha: 0.0, endFromAlpha: 1.0)
    }
    
}

/// Use this to fade in a viewcontroller. You can keep the previous view controller on screen or animate it out.
public class TranslucentAnimatedTransition: AnimatedTransition {
    
    /// The options used to animate the translucency of the view controllers
    public var translucentAnimationOptions: AnimationOptions
    
    public init(translucentAnimationOptions: AnimationOptions, presentation: Presentation) {
        self.translucentAnimationOptions = translucentAnimationOptions
        super.init(presentation: presentation)
    }
    
    override public func willStartAnimation(on toViewController: UIViewController, from fromViewController: UIViewController) {
        toViewController.view.alpha = translucentAnimationOptions.beginToAlpha
        fromViewController.view.alpha = translucentAnimationOptions.beginFromAlpha
    }
    
    override public func performAnimation(on toViewController: UIViewController, from fromViewController: UIViewController) {
        toViewController.view.alpha = translucentAnimationOptions.endToAlpha
        fromViewController.view.alpha = translucentAnimationOptions.endFromAlpha
    }
    
}

/// Use this transition to fade to a new view controller
public class TranslucentPresentAnimatedTransition: TranslucentAnimatedTransition {
    public init(translucentAnimationOptions: AnimationOptions) {
        super.init(translucentAnimationOptions: translucentAnimationOptions, presentation: .presenting)
    }
}

/// Use this transition to fade and dismiss to a view controller
public class TranslucentDismissAnimatedTransition: TranslucentAnimatedTransition {
    public init(translucentAnimationOptions: AnimationOptions) {
        super.init(translucentAnimationOptions: translucentAnimationOptions, presentation: .dismissing)
    }
}

