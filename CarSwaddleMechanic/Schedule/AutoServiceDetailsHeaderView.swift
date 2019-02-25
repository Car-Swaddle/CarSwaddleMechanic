//
//  AutoServiceDetailsHeaderView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/20/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store
import MessageUI

protocol AutoServiceDetailsHeaderViewDelegate: AnyObject {
    func present(viewController: UIViewController, header: AutoServiceDetailsHeaderView)
    func dismissMailComposeViewController(header: AutoServiceDetailsHeaderView)
}

final class AutoServiceDetailsHeaderView: UIView, NibInstantiating, MFMessageComposeViewControllerDelegate {
    
    
    weak var delegate: AutoServiceDetailsHeaderViewDelegate?
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var bannerView: LabeledBannerView!
    @IBOutlet private weak var callButton: UIButton!
    @IBOutlet private weak var smsButton: UIButton!
    
    private var autoService: AutoService?
    
    func configure(with autoService: AutoService) {
        self.autoService = autoService
        bannerView.label.text = self.statusString(for: autoService)
        nameLabel.text = autoService.creator?.displayName
    }
    
    private func statusString(for autoService: AutoService) -> String {
        switch autoService.status {
        case .canceled:
            return NSLocalizedString("Canceled", comment: "Auto service status")
        case .completed:
            return NSLocalizedString("Completed", comment: "Auto service status")
        case .inProgress:
            return NSLocalizedString("In Progress", comment: "Auto service status")
        case .scheduled:
            return NSLocalizedString("Scheduled", comment: "Auto service status")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func didTapCall() {
        guard let phoneNumber = self.phoneNumber,
            let url = URL(string: "tel://" + phoneNumber) else { return }
        UIApplication.shared.open(url)
    }
    
    private var phoneNumber: String? {
        return autoService?.creator?.phoneNumber
    }
    
    
    @IBAction func didTapSMS() {
        guard MFMessageComposeViewController.canSendText(),
            let phoneNumber = self.phoneNumber else { return }
        let controller = MFMessageComposeViewController()
        controller.recipients = [phoneNumber]
        controller.messageComposeDelegate = self
        delegate?.present(viewController: controller, header: self)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        delegate?.dismissMailComposeViewController(header: self)
    }
    
    
}
