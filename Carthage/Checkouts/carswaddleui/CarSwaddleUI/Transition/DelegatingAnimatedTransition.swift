import Foundation


/// Used with `DelegatingPresentAnimationController` to allow a viewcontroller to customize it's own transition.
public protocol DelegatingAnimatedTransitionDelegate {
    func willStartAnimation(for presentation: AnimatedTransition.Presentation)
    func performAnimation(for presentation: AnimatedTransition.Presentation)
    func didEndAnimation(for presentation: AnimatedTransition.Presentation)
}

/// Allows the viewcontroller to customize it's own transition.
/// Conform to `DelegatingAnimatedTransitionDelegate` and define your own animation.
public class DelegatingAnimatedTransition: AnimatedTransition {
    
    override public func willStartAnimation(on toViewController: UIViewController, from fromViewController: UIViewController) {
        if let viewController = toViewController as? DelegatingAnimatedTransitionDelegate {
            viewController.willStartAnimation(for: presentation)
        }
        if let viewController = fromViewController as? DelegatingAnimatedTransitionDelegate {
            viewController.willStartAnimation(for: presentation)
        }
        if let viewController = sourceViewController as? DelegatingAnimatedTransitionDelegate {
            viewController.willStartAnimation(for: presentation)
        }
    }
    
    override public func performAnimation(on toViewController: UIViewController, from fromViewController: UIViewController) {
        if let viewController = toViewController as? DelegatingAnimatedTransitionDelegate {
            viewController.performAnimation(for: presentation)
        }
        if let viewController = fromViewController as? DelegatingAnimatedTransitionDelegate {
            viewController.performAnimation(for: presentation)
        }
        if let viewController = sourceViewController as? DelegatingAnimatedTransitionDelegate {
            viewController.performAnimation(for: presentation)
        }
    }
    
    override public func didEndAnimation(on toViewController: UIViewController, from fromViewController: UIViewController) {
        if let viewController = toViewController as? DelegatingAnimatedTransitionDelegate {
            viewController.didEndAnimation(for: presentation)
        }
        if let viewController = fromViewController as? DelegatingAnimatedTransitionDelegate {
            viewController.didEndAnimation(for: presentation)
        }
        if let viewController = sourceViewController as? DelegatingAnimatedTransitionDelegate {
            viewController.didEndAnimation(for: presentation)
        }
    }
    
}
