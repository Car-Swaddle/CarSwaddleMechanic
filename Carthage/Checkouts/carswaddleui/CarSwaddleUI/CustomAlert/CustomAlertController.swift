
import UIKit

private let topContentInsetConstantNoImage: CGFloat = 32
private let topContentInsetConstantWithImage: CGFloat = 16

private let alertCornerRadius: CGFloat = 16

/// Use this to display information to the user in place of a `UIAlertController`.
/// Create an instance with a `CustomAlert`
final public class CustomAlertController: UIViewController, StoryboardInstantiating {
    
    // MARK: - Public
    
    // only one content view is allowed for now. Expand this to multiple when `next` and/or `back` is a requirement
    public static func viewController(contentView: CustomAlertContentView) -> CustomAlertController {
        let alert = CustomAlertController.viewControllerFromStoryboard()
        alert.setupTransition()
        alert.contentViews = [contentView]
        return alert
    }
    
    /// If `true` a dismiss button will be displayed on the top right of the alert view.
    public var displayDismissButton: Bool = false {
        didSet {
            updateDismissButtonDisplay()
        }
    }
    
    /// If `true` then when the view behind the alert view is tapped, the alert will dismiss.
    public var tapBackgroundToDismiss: Bool = false
    
    
    /// All content views that can be displayed
    /// Currently there can only be one content view set.
    public private(set) var contentViews: [CustomAlertContentView] = []
    
    /// Image that is displayed on the alertView itself (not an alert content view).
    public var topImage: UIImage? {
        didSet {
            guard viewIfLoaded != nil else { return }
            setTopImage()
        }
    }
    
    /// The height of `topImage`. This should only be set if you want a height explicitly. If you do not set this
    /// the aspect ratio will be preserved and the image's width will be set to the alert view's width.
    public var topImageHeight: CGFloat? {
        didSet {
            updateTopImageHeightIfNeeded()
        }
    }
    
    
    // MARK: - Private
    
    private var translucentDismissAnimator = TranslucentDismissAnimatedTransition(translucentAnimationOptions: .overDismiss)
    private var presentAnimator = ZoomPresentAnimatedTransition()
    
    
    @IBOutlet private weak var topImageView: UIImageView!
    @IBOutlet private weak var alertView: UIView!
    @IBOutlet private weak var contentContainerView: UIView!
    @IBOutlet private weak var dismissButton: UIButton!
    
    @IBOutlet private weak var minHeightFromBottom: NSLayoutConstraint!
    @IBOutlet private weak var verticalCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var topImageViewHeightConstraint: NSLayoutConstraint!
    
    private var originalMinHeightConstant: CGFloat = 0
    
    @IBOutlet private var topConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private var topContentConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomContentConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var alertViewWidthConstraint: NSLayoutConstraint!
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTransition()
        setupContentView()
        registerForKeyboardEvents()
        originalMinHeightConstant = minHeightFromBottom.constant
        updateDismissButtonDisplay()
        setTopImage()
        view.layoutIfNeeded()
        updateTopImageHeightIfNeeded()
        updateTopContentInset()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return presentingViewController?.preferredStatusBarStyle ?? .default
    }
    
    public override var prefersStatusBarHidden: Bool {
        return presentingViewController?.prefersStatusBarHidden ?? false
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeAreasInsets = view.safeAreaInsets.top + view.safeAreaInsets.bottom
        let contentInsets = topConstraint.constant + bottomConstraint.constant + topContentConstraint.constant + bottomContentConstraint.constant
        let maxHeight = view.frame.height - (safeAreasInsets + contentInsets + topImageViewHeightConstraint.constant)
        for contentView in contentViews {
            contentView.maxHeight = maxHeight
        }
    }
    
    private func setTopImage() {
        topImageView.image = topImage
        updateTopContentInset()
        updateTopImageHeightIfNeeded()
        view.layoutIfNeeded()
    }
    
    private func updateTopContentInset() {
        guard viewIfLoaded != nil else { return }
        let constant = topImage == nil ? topContentInsetConstantNoImage : topContentInsetConstantWithImage
        topContentConstraint.constant = constant
    }
    
    private func updateTopImageHeightIfNeeded() {
        guard viewIfLoaded != nil else { return }
        guard let newImage = topImage else {
            topImageViewHeightConstraint.constant = 0
            return
        }
        let height = topImageHeight ?? newImage.size.aspectRatio * alertViewWidthConstraint.constant
        topImageViewHeightConstraint.constant = height
    }
    
    private func updateDismissButtonDisplay() {
        dismissButton?.isHidden = !displayDismissButton
    }
    
    private func registerForKeyboardEvents() {
        let notificationNames: [Notification.Name] = [UIResponder.keyboardDidHideNotification, UIResponder.keyboardDidShowNotification, UIResponder.keyboardWillHideNotification, UIResponder.keyboardWillShowNotification, UIResponder.keyboardDidChangeFrameNotification, UIResponder.keyboardWillChangeFrameNotification]
        
        for name in notificationNames {
            NotificationCenter.default.addObserver(self, selector: #selector(CustomAlertController.keyboardChanged(_:)), name: name, object: nil)
        }
    }
    
    @objc private func keyboardChanged(_ notification: Notification) {
        let keyboardHeight = view.keyboardHeightFromBottomWithNotification(notification)
        verticalCenterConstraint.constant = -keyboardHeight/2
        minHeightFromBottom.constant = originalMinHeightConstant + keyboardHeight
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupTopImageMask()
    }
    
    private func setupContentView() {
        alertView.layer.cornerRadius = alertCornerRadius
        alertView.layer.shadowOffset = CGSize(width: 1, height: 3)
        alertView.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.3).cgColor
        alertView.layer.shadowOpacity = 1
        alertView.layer.shadowRadius = 13
        
        for contentView in contentViews {
            contentContainerView.addSubview(contentView)
            contentView.pinFrameToSuperViewBounds()
            contentView.delegate = self
        }
    }
    
    private func setupTopImageMask() {
        let path = UIBezierPath(roundedRect: topImageView.bounds,
                                byRoundingCorners: [.topRight, .topLeft],
                                cornerRadii: CGSize(width: alertCornerRadius, height:  alertCornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        topImageView.layer.mask = maskLayer
    }
    
    private func setupTransition() {
        modalPresentationStyle = .custom
        modalPresentationCapturesStatusBarAppearance = true
        transitioningDelegate = self
    }
    
    @IBAction private func didSelectExit() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackgroundView(_ tap: UITapGestureRecognizer) {
        guard tapBackgroundToDismiss else { return }
        dismiss(animated: true, completion: nil)
    }
    
    override public var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return traitCollection.isAllRegular ? .all : .portrait
    }
    
}

extension CustomAlertController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return translucentDismissAnimator
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }
    
}

extension CustomAlertController: CustomAlertContentViewDelegate {
    
    func dismiss(_ customAlertContentView: CustomAlertContentView) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension CustomAlertController: ZoomContentViewContaining {
    
    public var zoomContentView: UIView {
        return alertView
    }
    
}
