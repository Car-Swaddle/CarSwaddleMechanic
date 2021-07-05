//
//  AutoServicesHeaderView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/18/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Lottie
import CarSwaddleStore
import UIKit

final class AutoServicesHeaderView: UIView, NibInstantiating {
    
    public var dayHasAutoServices: Bool = true {
        didSet {
            timelineView?.isHidden = !dayHasAutoServices
        }
    }
    
    public var date: Date? {
        didSet {
            updateTimelineBannerLabel()
        }
    }
    
    private var timelineView: UIView?
    
    private static var timelineBuilder = TimelineUIBuilder()
    
    @IBOutlet private weak var bannerView: LabeledBannerView!
    
    private func updateTimelineBannerLabel() {
        bannerView.label.text = timelineBannerString
    }
    
    private var timelineBannerString: String {
        guard let date = date else { return "" }
        let weekdayString = weekdayMonthDayDateFormatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            let todayFormatString = NSLocalizedString("Today • %@", comment: "Today, a dot then the day of the week and the day of the month")
            return String(format: todayFormatString, weekdayString)
        } else if Calendar.current.isDateInTomorrow(date) {
            let tomorrowFormatString = NSLocalizedString("Tomorrow • %@", comment: "Today, a dot then the day of the week and the day of the month")
            return String(format: tomorrowFormatString, weekdayString)
        } else {
            return weekdayString
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let timelineView = AutoServicesHeaderView.timelineBuilder.addTimelineHairline(to: self)
        self.timelineView = timelineView
        AutoServicesHeaderView.timelineBuilder.addConstraints(toTimelineView: timelineView, on: self)
    }
    
}



@IBDesignable
public class LabeledBannerView: UIView {
    
    @IBInspectable
    public var labelTextColor: UIColor {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }
    
    @IBInspectable
    public lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(type: .semiBold, size: 17)
        label.autoresizingMask = []
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public var image: UIImage? {
        didSet {
            imageView.image = image
            if image == nil {
                imageView.isHiddenInStackView = true
            } else {
                imageView.isHiddenInStackView = false
            }
        }
    }
    
    public var lottieAnimation: String? {
        didSet {
            if let lottieAnimation = lottieAnimation {
                lottieView.animation = Animation.named(lottieAnimation)
                lottieView.play()
                lottieView.loopMode = .loop
                lottieView.isHiddenInStackView = false
            } else {
                lottieView.animation = nil
                lottieView.stop()
                lottieView.isHiddenInStackView = true
            }
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var lottieView: AnimationView = {
        let view = AnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layer.mask = shapeLayerWithRoundedCorners([.topRight, .bottomRight], radius: frame.height/2)
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    private func setup() {
        addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: TimelineUIBuilder.labelOffset).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -TimelineUIBuilder.labelOffset).isActive = true
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.alignment = .center
        stackView.spacing = 8
        
        stackView.addArrangedSubview(imageView)
        
        imageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        imageView.isHiddenInStackView = true
        imageView.tintColor = .white
        
        stackView.addArrangedSubview(lottieView)
        
        lottieView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        lottieView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        lottieView.isHiddenInStackView = true
        
        stackView.addArrangedSubview(label)
    }
    
}


extension LabeledBannerView {
    
    func configure(for status: AutoService.Status) {
        switch status {
        case .completed, .scheduled, .canceled:
            image = status.image
            lottieAnimation = nil
        case .inProgress:
            lottieAnimation = LottieAnimation.inProgress.fileName
            image = nil
        }
    }
    
}

public extension UIView {
    
    func shapeLayerWithRoundedCorners(_ corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        return CAShapeLayer.withRoundedCorners(corners, bounds: bounds, radius: radius)
    }
    
}

public extension CAShapeLayer {
    
    static func withRoundedCorners(_ corners: UIRectCorner, bounds: CGRect, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        return maskLayer
    }
    
}


final class TimelineUIBuilder {
    
    static let labelOffset: CGFloat = 24
    static let timelineViewBackgroundColor: UIColor = .background
    
    @discardableResult
    func addTimelineHairline(to superView: UIView) -> UIView {
        let timelineView = UIView()
        timelineView.autoresizingMask = []
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.backgroundColor = TimelineUIBuilder.timelineViewBackgroundColor
        
        superView.insertSubview(timelineView, at: 0)
        
//        let widthConstraint = timelineView.widthAnchor.constraint(equalToConstant: (1.0 / UIScreen.main.scale) * 2)
//        widthConstraint.isActive = true
//        let leadingConstraint = timelineView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: TimelineUIBuilder.labelOffset)
//        leadingConstraint.isActive = true
//        let topConstraint = timelineView.topAnchor.constraint(equalTo: superView.topAnchor)
//        topConstraint.isActive = true
//        let bottomConstraint = timelineView.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
//        bottomConstraint.isActive = true
        
        return timelineView
    }
    
    @discardableResult
    func addConstraints(toTimelineView timelineView: UIView, on superView: UIView) -> (widthConstraint: NSLayoutConstraint, leadingConstraint: NSLayoutConstraint, topConstraint: NSLayoutConstraint, bottomConstraint: NSLayoutConstraint) {
        let widthConstraint = timelineView.widthAnchor.constraint(equalToConstant: (1.0 / UIScreen.main.scale) * 2)
        widthConstraint.isActive = true
        let leadingConstraint = timelineView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: TimelineUIBuilder.labelOffset)
        leadingConstraint.isActive = true
        let topConstraint = timelineView.topAnchor.constraint(equalTo: superView.topAnchor)
        topConstraint.isActive = true
        let bottomConstraint = timelineView.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        bottomConstraint.isActive = true
        
        return (widthConstraint, leadingConstraint, topConstraint, bottomConstraint)
    }
    
}
