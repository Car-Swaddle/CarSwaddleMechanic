//
//  MechanicImageView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/7/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleData
import CarSwaddleUI

final class MechanicImageView: UIImageView {
    
    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    private var mechanicID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        image = UIImage.from(color: .gray3)
        backgroundColor = .gray3
        layer.cornerRadius = defaultCornerRadius
        layer.masksToBounds = true
        contentMode = .scaleAspectFill
    }
    
    public func configure(withMechanicID mechanicID: String) {
        self.mechanicID = mechanicID
        
        if let userImage = profileImageStore.getImage(forMechanicWithID: mechanicID, in: store.mainContext) {
            image = userImage
        } else {
            store.privateContext { [weak self] context in
                self?.mechanicNetwork.getProfileImage(mechanicID: mechanicID, in: context) { fileURL, error in
                    guard self?.mechanicID == mechanicID else { return }
                    DispatchQueue.main.async {
                        self?.image = profileImageStore.getImage(forMechanicWithID: mechanicID, in: store.mainContext)
                    }
                }
            }
        }
    }
    
}
