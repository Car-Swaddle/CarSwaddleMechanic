//
//  AutoServiceDetailsHeaderView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/20/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleStore
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
        bannerView.backgroundColor = autoService.status.color
        nameLabel.text = autoService.creator?.displayName
        bannerView.configure(for: autoService.status)
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
        
        bannerView.label.text = nil
        nameLabel.text = nil
    }
    
    @IBAction private func didTapCall() {
        guard let phoneNumber = self.phoneNumber?.replacingOccurrences(of: " ", with: ""),
            let url = URL(string: "tel://" + phoneNumber) else { return }
        UIApplication.shared.open(url)
    }
    
    private var phoneNumber: String? {
        return autoService?.creator?.phoneNumber
    }
    
    
    @IBAction private func didTapSMS() {
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
