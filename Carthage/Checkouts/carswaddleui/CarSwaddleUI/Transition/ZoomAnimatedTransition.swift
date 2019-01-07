import Foundation

/// Used with `ZoomOutPresentAnimatedTransition` to provide the correct view to zoom.
public protocol ZoomContentViewContaining {
    var zoomContentView: UIView { get }
}

/// Use this to zoom into the viewcontrollers self.view property or a provided content view
public class ZoomAnimatedTransition: TranslucentAnimatedTransition {
    
    /// Create an instance of `ZoomOutPresentAnimationController`.
    ///
    /// - Parameters:
    ///   - duration: Duration of animation
    ///   - animationOptions: Options used to change the animation
    ///   - initialZoomTransform: The transform to be applied to self.view or the content view before the animation begins.
    public init(initialZoomTransform: CGAffineTransform = CGAffineTransform(scaleX: 1.1, y: 1.1), translucentAnimationOptions: TranslucentAnimatedTransition.AnimationOptions, presentation: Presentation) {
        self.initialZoomTransform = initialZoomTransform
        super.init(translucentAnimationOptions: translucentAnimationOptions, presentation: presentation)
        self.animationOptions = .curveEaseInOut
    }
    
    private(set) var initialZoomTransform: CGAffineTransform
    
    override public func willStartAnimation(on toViewController: UIViewController, from fromViewController: UIViewController) {
        super.willStartAnimation(on: toViewController, from: fromViewController)
        if let contentContaining = toViewController as? ZoomContentViewContaining {
            contentContaining.zoomContentView.transform = initialZoomTransform
        } else {
            toViewController.view.transform = initialZoomTransform
        }
    }
    
    override public func performAnimation(on toViewController: UIViewController, from fromViewController: UIViewController) {
        super.performAnimation(on: toViewController, from: fromViewController)
        if let contentContaining = toViewController as? ZoomContentViewContaining {
            contentContaining.zoomContentView.transform = .identity
        } else {
            toViewController.view.transform = .identity
        }
    }
    
}


/// Use this for a zoom present transition. It will fade the toViewController and zoom it.
/// You can adjust the zoom as needed
public class ZoomPresentAnimatedTransition: ZoomAnimatedTransition {
    
    public init(initialZoomTransform: CGAffineTransform = CGAffineTransform(scaleX: 1.1, y: 1.1), translucentAnimationOptions: TranslucentAnimatedTransition.AnimationOptions = .overPresent) {
        super.init(initialZoomTransform: initialZoomTransform, translucentAnimationOptions: translucentAnimationOptions, presentation: .presenting)
    }
    
}

/// Use this for a zoom dismiss transition. It will fade the toViewController and zoom it.
/// You can adjust the zoom as needed
public class ZoomDismissAnimatedTransition: ZoomAnimatedTransition {
    
    public init(initialZoomTransform: CGAffineTransform = CGAffineTransform(scaleX: 1.1, y: 1.1), translucentAnimationOptions: TranslucentAnimatedTransition.AnimationOptions = .overDismiss) {
        super.init(initialZoomTransform: initialZoomTransform, translucentAnimationOptions: translucentAnimationOptions, presentation: .dismissing)
    }
    
}

