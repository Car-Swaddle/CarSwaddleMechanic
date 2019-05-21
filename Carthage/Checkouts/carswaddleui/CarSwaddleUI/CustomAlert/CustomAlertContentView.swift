
import UIKit
//import Lottie


private let defaultTitleTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0.4470588235, green: 0.6901960784, blue: 0.8431372549, alpha: 1), .font: UIFont.systemFont(ofSize: 17, weight: .medium)]
private let defaultMessageTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6), .font: UIFont.systemFont(ofSize: 14)]

private let buttonTitleFont = UIFont.systemFont(ofSize: 15, weight: .medium)
private let buttonContentInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)


/// An action that can be taken when the user taps a button on a CustomAlert.
///
/// Call `init(title:handler:)` to create an action.
/// Every tap will dismiss the alert. Do not call `dismiss` in the handler.
/// Add an instance of `CustomAlertAction` to `CustomAlertContentView` with `addAction(action:)` before displaying the view to the user.
public final class CustomAlertAction: NSObject {
    
    /// Creates and returns an action with the specified title and handler.
    ///
    /// - Parameters:
    ///   - title: Title of the actions button
    ///   - handler: Closure called when the user taps the corresponding button
    public init(title: String?, handler: ((CustomAlertAction) -> Void)? = nil) {
        self.title = title
        self.handler = handler
    }
    
    /// The title of the actions button
    public private(set) var title: String?
    
    /// Indicates whether the button is enabled.
    /// This changes the style of the button to indicate it is enabled or disabled.
    public var isEnabled: Bool = true {
        didSet {
            if oldValue == isEnabled { return }
            isEnabledDidChange?(isEnabled)
        }
    }
    
    fileprivate var isEnabledDidChange: ((_ newValue: Bool) -> ())?
    fileprivate var handler: ((CustomAlertAction) -> Void)?
    
}

/// Protocol used to communicate to CustomAlert
protocol CustomAlertContentViewDelegate: class {
    /// The sender requests to dismiss the current view controller
    func dismiss(_ customAlertContentView: CustomAlertContentView)
}


/// The display of one piece of content on a `CustomAlertController`.
/// This holds the image, lottie, title, message and any buttons.
public final class CustomAlertContentView: UIView, NibInstantiating {
    
    // MARK: - Public
    
    public static func view(withTitle title: String? = nil, message: String? = nil) -> CustomAlertContentView {
        let view = CustomAlertContentView.viewFromNib()
        view.titleText = title
        view.messageText = message
        return view
    }
    
    /// Title displayed in the content
    public var titleText: String? {
        get {
            return attributedTitleText?.string
        }
        set {
            guard let titleText = newValue else {
                attributedTitleText = nil
                return
            }
            attributedTitleText = NSAttributedString(string: titleText, attributes: defaultTitleTextAttributes)
        }
    }
    
    /// Message that describes the reason for the alert.
    public var messageText: String? {
        get {
            return attributedMessageText?.string
        }
        set {
            guard let messageText = newValue else {
                attributedMessageText = nil
                return
            }
            attributedMessageText = NSAttributedString(string: messageText, attributes: defaultMessageTextAttributes)
        }
    }
    
    /// Title displayed in the content. The display will respect the last value set
    /// between `attributedTitleText` and `titleText`
    public var attributedTitleText: NSAttributedString? {
        didSet {
            updateTitleLabelDisplay()
            titleLabel.attributedText = attributedTitleText
        }
    }
    
    /// Message displayed in the content. The display will respect the last value set
    /// between `attributedMessageText` and `messageText`
    public var attributedMessageText: NSAttributedString? {
        didSet {
            updateMessageLabelDisplay()
            messageLabel.attributedText = attributedMessageText
        }
    }
    
    /// Image centered above the title.
    public var image: UIImage? {
        didSet {
            imageView.image = image
            updateImageDisplay()
        }
    }
    
    public var normalButtons: [UIButton]  {
        var normalButtons: [UIButton] = []
        for key in actionsButtons.keys {
            guard key != preferredAction else { continue }
            if let button = actionsButtons[key] {
                normalButtons.append(button)
            }
        }
        return normalButtons
    }
    
    /// Call this to add a lottie animation. If called twice it will only take the last lottie animation.
    ///
    /// - Parameters:
    ///   - name: name of the lottie in the file system. Must include the file type `.json`.
    ///   - bundle: Lottie animation's bundle. The bundle where the JSON lives.
    ///   - size: Size of the lottie to be displayed. If the size is bigger than the content view it will shrink to the width of the alert and the aspect ratio will be preserved.
    ///   - configurationHandler: A closure called when the lottieview is finished setting up. Make use of the LOTAnimationView API to customize such as `loopAnimation = false`.
    ///   - bundle: The bundle in which to search for the provided lottie file
//    public func addLottie(withName name: String, bundle: Bundle = Bundle.main, size: CGSize, configurationHandler: ((_ lottieAnimationView: LOTAnimationView) -> Void)? = nil) {
//        lottieAnimationView?.removeFromSuperview()
//
//        lottieContentView.isHidden = false
//
//        let animationView = LOTAnimationView(name: name, bundle: bundle)
//        animationView.play()
//        animationView.loopAnimation = true
//
//        lottieContentView.addSubview(animationView)
//        animationView.pinFrameToSuperViewBounds()
//        lottieAnimationView = animationView
//        lottieContentViewWidthConstraint.constant = size.width
//        lottieContentViewHeightConstraint.constant = size.height
//
//        let newAspectRatio = size.aspectRatio
//        let newAspectRatioConstraint = NSLayoutConstraint(item: lottieContentView, attribute: .height, relatedBy: .equal, toItem: lottieContentView, attribute: .width, multiplier: newAspectRatio, constant: 0)
//        lottieAspectRatioConstraint = newAspectRatioConstraint
//
//        configurationHandler?(animationView)
//    }
    
    /// Add one or many text fields to the alert. Use the closure to configure your text field as needed.
    ///
    /// - Parameter configurationHandler: Closure called when the textField is finished setting up
    public func addTextField(configurationHandler: ((_ textField: UITextField) -> Void)? = nil) {
        let textField = self.configuredTextField()
        labelStackView.addArrangedSubview(textField)
        textField.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: labelStackView.trailingAnchor).isActive = true
        textFields.append(textField)
        configurationHandler?(textField)
    }
    
    /// Add one or many text fields to the alert. Use the closure to configure your text field as needed.
    ///
    /// - Parameter configurationHandler: Closure called when the textField is finished setting up
    public func addCustomView(configurationHandler: ((_ customView: UIView) -> Void)? = nil) {
        let customView = UIView()
        customView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.addArrangedSubview(customView)
        customView.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor).isActive = true
        customView.trailingAnchor.constraint(equalTo: labelStackView.trailingAnchor).isActive = true
        configurationHandler?(customView)
    }
    
    /// Add one or more switches to the content. These will be added to the action section of the content view
    ///
    /// - Parameter configurationHandler: Closure called when the switch and label are done settings up
    public func addSwitch(configurationHandler: ((_ actionSwitch: UISwitch, _ switchLabel: UILabel) -> Void)? = nil) {
        let actionSwitch = UISwitch()
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let rightSpacer = UIView()
        rightSpacer.translatesAutoresizingMaskIntoConstraints = false
        rightSpacer.widthAnchor.constraint(equalToConstant: 0).isActive = true
        rightSpacer.backgroundColor = .clear
        
        let leftSpacer = UIView()
        leftSpacer.backgroundColor = .clear
        
        let switchStackView = UIStackView(arrangedSubviews: [leftSpacer, label, actionSwitch, rightSpacer])
        switchStackView.axis = .horizontal
        switchStackView.alignment = .center
        switchStackView.spacing = 8
        
        // UISwitch has a 3 point outline for it's tintColor, add this or it will go outside of the bounds
        switchStackView.setCustomSpacing(3, after: actionSwitch)
        
        let previousViewOptional = buttonStackView.arrangedSubviews.last
        buttonStackView.addArrangedSubview(switchStackView)
        if let previousView = previousViewOptional {
            buttonStackView.setCustomSpacing(16, after: previousView)
        }
        
        actionSwitches.append(actionSwitch)
        configurationHandler?(actionSwitch, label)
    }
    
    /// Add a `CustomAlertAction` to the content view. Displays a button
    /// that the user can tap. The buttons handler will be called on button tap.
    ///
    /// - Parameter action: CustomAlertAction to be added to the content view.
    public func addAction(_ action: CustomAlertAction) {
        let button = self.button(from: action)
        
        buttonStackView.addArrangedSubview(button)
        actionsButtons[action] = button
        buttonsActions[button] = action
        actions.append(action)
        
        action.isEnabledDidChange = { [weak self] isEnabled in
            DispatchQueue.main.async {
                guard let button = self?.actionsButtons[action] else {
                    return
                }
                button.isEnabled = isEnabled
            }
        }
        
        updateButtonStackViewAxis()
    }
    
    /// Styles the action with the default preferred action styling.
    public weak var preferredAction: CustomAlertAction? {
        didSet {
            if let oldValue = oldValue,
                let oldValueButton = actionsButtons[oldValue] {
                configureButtonForDefault(oldValueButton)
            }
            if let preferredAction = preferredAction,
                let newValueButton = actionsButtons[preferredAction] {
                configureButtonForPreferred(newValueButton)
            }
            // if the button doesn't exist yet, it will be configured correctly when it is added.
        }
    }
    
    public var preferredButton: UIButton? {
        guard let preferredAction = preferredAction else { return nil }
        return actionsButtons[preferredAction]
    }
    
    // MARK: - Internal
    
    internal var maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude {
        didSet {
            setNeedsLayout()
        }
    }
    
    internal var delegate: CustomAlertContentViewDelegate?
    
    // MARK: - Private properties
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var lottieContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    
    @IBOutlet private weak var contentStackView: UIStackView!
    
    @IBOutlet private weak var topScrollView: UIScrollView!
    @IBOutlet private weak var bottomScrollView: UIScrollView!
    
    @IBOutlet private weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var labelScrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelScrollViewMinHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelStackView: UIStackView!
    
    @IBOutlet private weak var buttonScrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonScrollViewMaxHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonStackView: UIStackView!
    
    @IBOutlet private weak var lottieContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var lottieContentViewWidthConstraint: NSLayoutConstraint!
    
    
    
    private var actions: [CustomAlertAction] = []
    private var actionsButtons: [CustomAlertAction: UIButton] = [:]
    private var buttonsActions: [UIButton: CustomAlertAction] = [:]
    
    
    /// All switches added to the content view
    public private(set) var actionSwitches: [UISwitch] = []
    
    /// All text fields added to the content view
    public private(set) var textFields: [UITextField] = []
    
    /// All custom views added to the content view
    public private(set) var customViews: [UIView] = []
    
    private var underlineViews: [UITextField: UIView] = [:]
    
//    private var lottieAnimationView: LOTAnimationView?
    
    // MARK: - Overrides
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        image = nil
        buttonStackView.distribution = .fillEqually
        lottieContentViewWidthConstraint.constant = 0
        lottieContentViewHeightConstraint.constant = 0
        lottieContentView.isHidden = true
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        labelScrollViewHeightConstraint.constant = labelStackView.frame.height
        buttonScrollViewHeightConstraint.constant = buttonStackView.frame.height
        
        updateButtonStackViewAxis()
        buttonScrollViewMaxHeightConstraint.constant = min(buttonStackView.frame.height, 100)
        labelScrollViewMinHeightConstraint.constant = min(labelStackView.frame.height, 80)
    }
    
    // MARK: - Private Methods
    
    // MARK: Button
    
    private func button(from action: CustomAlertAction) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        
        button.layer.cornerRadius = 8
        button.layer.shadowOffset = CGSize(width: 1, height: 2)
        button.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.05).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 8
        
        button.contentEdgeInsets = buttonContentInsets
        
        if preferredAction == action {
            configureButtonForPreferred(button)
        } else {
            configureButtonForDefault(button)
        }
        
        button.setTitle(action.title, for: .normal)
        button.titleLabel?.font = buttonTitleFont
        
        button.addTarget(self, action: #selector(CustomAlertContentView.didTapButton(_:)), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.6
        button.titleLabel?.lineBreakMode = .byTruncatingMiddle
        button.titleLabel?.baselineAdjustment = .alignCenters
        
        button.isEnabled = action.isEnabled
        
        return button
    }
    
    @objc private func didTapButton(_ button: UIButton) {
        guard let action = buttonsActions[button] else { return }
        delegate?.dismiss(self)
        DispatchQueue.main.async {
            action.handler?(action)
        }
    }
    
    private func configureButtonForDefault(_ button: UIButton) {
        button.setTitleColor(#colorLiteral(red: 0.3058823529, green: 0.5490196078, blue: 0.7294117647, alpha: 1), for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.1921568627, green: 0.4078431373, blue: 0.6078431373, alpha: 1), for: .highlighted)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        
        let background = UIColor(white255: 244)
        
        button.setBackgroundImage(UIImage.from(color: background), for: .normal)
        button.setBackgroundImage(UIImage.from(color: background.color(adjustedBy255Points: -40)), for: .highlighted)
    }
    
    private func configureButtonForPreferred(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1), for: .highlighted)
        
        button.layer.borderWidth = 0
        
        let backgroundColor: UIColor = #colorLiteral(red: 0.4117647059, green: 0.7450980392, blue: 0.6588235294, alpha: 1)
        
        button.setBackgroundImage(UIImage.from(color: backgroundColor), for: .normal)
        button.setBackgroundImage(UIImage.from(color: backgroundColor.color(adjustedBy: -0.1)), for: .highlighted)
    }
    
    private func updateButtonStackViewAxis() {
        buttonStackView.axis = buttonStackViewAxis
    }
    
    private var buttonStackViewAxis: NSLayoutConstraint.Axis {
        if actions.count > 2 || actionSwitches.count > 0 {
            return .vertical
        } else {
            if buttonsFitOnOneLine {
                return .horizontal
            } else {
                return .vertical
            }
        }
    }
    
    private var buttonsFitOnOneLine: Bool {
        if actions.count == 0 || actions.count == 1 { return true }
        if actions.count != 2 { return false }
        let firstAction = actions[0]
        let secondAction = actions[1]
        
        let firstButtonTextWidth = (firstAction.title as NSString?)?.size(withAttributes: [.font: buttonTitleFont]).width ?? 0
        let secondButtonTextWidth = (secondAction.title as NSString?)?.size(withAttributes: [.font: buttonTitleFont]).width ?? 0
        
        let singleButtonHorizontalContentInsets = buttonContentInsets.left + buttonContentInsets.right
        
        let maxSingleButtonWidth = frame.width / 2
        
        let firstButtonLeftOverWidth = maxSingleButtonWidth - (firstButtonTextWidth + singleButtonHorizontalContentInsets)
        let secondButtonLeftOverWidth = maxSingleButtonWidth - (secondButtonTextWidth + singleButtonHorizontalContentInsets)
        
        if firstButtonLeftOverWidth >= 0 && secondButtonLeftOverWidth >= 0 {
            return true
        } else {
            return false
        }
    }
    
    /// Used to preserve aspect ratio if the height or width is not able to change to the images size.
    private var imageViewAspectRatioConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            if let constraint = imageViewAspectRatioConstraint {
                imageView.addConstraint(constraint)
            }
        }
    }
    
    private var lottieAspectRatioConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            if let constraint = lottieAspectRatioConstraint {
                lottieContentView.addConstraint(constraint)
            }
        }
    }
    
    private func configuredTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        let underlineView = textField.addHairlineView(toSide: .bottom, color: #colorLiteral(red: 0.5647058824, green: 0.768627451, blue: 0.8941176471, alpha: 1), size: 3.0)
        underlineView.isHidden = true
        underlineViews[textField] = underlineView
        textField.layer.cornerRadius = 3
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.clipsToBounds = true
        let constraint = textField.widthAnchor.constraint(lessThanOrEqualToConstant: 180)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        
        textField.addTarget(self, action: #selector(CustomAlertContentView.didBeginEditingTextField(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(CustomAlertContentView.didEndEditingTextField(_:)), for: .editingDidEnd)
        
        textField.font = UIFont.systemFont(ofSize: 14)
        
        return textField
    }
    
    @objc private func didBeginEditingTextField(_ textField: UITextField) {
        underlineViews[textField]?.isHidden = false
    }
    
    @objc private func didEndEditingTextField(_ textField: UITextField) {
        underlineViews[textField]?.isHidden = true
    }
    
    private func updateImageDisplay() {
        imageView.isHidden = !shouldShowImage
        guard let image = image else {
            imageHeightConstraint.constant = 0
            imageWidthConstraint.constant = 0
            imageViewAspectRatioConstraint = nil
            return
        }
        imageHeightConstraint.constant = image.size.height
        imageWidthConstraint.constant = image.size.width
        let newAspectRatio = image.size.aspectRatio
        let newAspectRatioConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: newAspectRatio, constant: 0)
        imageViewAspectRatioConstraint = newAspectRatioConstraint
    }
    
    private var shouldShowImage: Bool {
        return image != nil
    }
    
    private func updateTitleLabelDisplay() {
        titleLabel.isHidden = !shouldShowTitleLabel
    }
    
    private var shouldShowTitleLabel: Bool {
        guard let titleText = titleText else { return false }
        return !titleText.isEmpty
    }
    
    private func updateMessageLabelDisplay() {
        messageLabel.isHidden = !shouldShowMessageLabel
    }
    
    private var shouldShowMessageLabel: Bool {
        guard let messageText = messageText else { return false }
        return !messageText.isEmpty
    }
    
}
