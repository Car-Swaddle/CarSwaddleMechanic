import Foundation


/// Base class for animated transitions
open class AnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    public static let defaultTransitionDuration: TimeInterval = 0.25
    
    public enum Presentation {
        case presenting
        case dismissing
    }
    
    open var presentation: Presentation
    
    public init(duration: TimeInterval = AnimatedTransition.defaultTransitionDuration, animationOptions: UIView.AnimationOptions = [], presentation: Presentation) {
        self.transitionDuration = duration
        self.animationOptions = animationOptions
        self.presentation = presentation
    }
    
    /// The duration of going from one viewcontroller to the next
    open var transitionDuration: TimeInterval = AnimatedTransition.defaultTransitionDuration
    
    /// Options passed into UIView.animate(…) defaults to []
    open var animationOptions: UIView.AnimationOptions
    
    internal final var transitionContext: UIViewControllerContextTransitioning?
    internal final var toViewController: UIViewController?
    internal final var fromViewController: UIViewController?
    internal final var sourceViewController: UIViewController?
    
    final public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    final public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        
        self.toViewController = toViewController
        self.fromViewController = fromViewController
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView
        
        switch presentation {
        case .dismissing:
            switch fromViewController.modalPresentationStyle {
            case .currentContext, .overCurrentContext:
                toViewController.view.frame = fromViewController.view.frame
            case .fullScreen, .custom, .overFullScreen, .none:
                toViewController.view.frame = transitionContext.containerView.frame
            case .popover, .pageSheet, .formSheet:
                fatalError("This model presentation style is not supported. Add it!")
            @unknown default:
                fatalError("unkown presentation style")
            }
        case .presenting:
            containerView.addSubview(toViewController.view)
            
            switch toViewController.modalPresentationStyle {
            case .currentContext, .overCurrentContext:
                toViewController.view.frame = fromViewController.view.frame
            case .fullScreen, .custom, .overFullScreen, .none:
                toViewController.view.frame = transitionContext.containerView.frame
            case .popover, .pageSheet, .formSheet:
                fatalError("This model presentation style is not supported. Add it!")
            @unknown default:
                fatalError("unkown presentation style")
            }
        }
        
        let duration = transitionDuration(using: transitionContext)
        
        self.willStartAnimation(on: toViewController, from: fromViewController)
        UIView.animate(withDuration: duration, delay: 0.0, options: self.animationOptions, animations: {
            self.performAnimation(on: toViewController, from: fromViewController)
        }) { isFinished in
            self.didEndAnimation(on: toViewController, from: fromViewController)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    /// Called right before `UIView.animated` is called
    ///
    /// - Parameter toViewController: The view controller to be presented.
    open func performAnimation(on toViewController: UIViewController, from fromViewController: UIViewController) { }
    
    /// Called in the animations block for `UIView.animated`
    ///
    /// - Parameter toViewController: The view controller to be presented.
    open func willStartAnimation(on toViewController: UIViewController, from fromViewController: UIViewController) { }
    
    /// Called when the `UIView.animated` completion is called
    ///
    /// - Parameter toViewController: The view controller to be presented.
    open func didEndAnimation(on toViewController: UIViewController, from fromViewController: UIViewController) { }
    
}

