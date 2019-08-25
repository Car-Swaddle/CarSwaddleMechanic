//
//  TransactionReceiptCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/5/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store
import CarSwaddleData
import CarSwaddleNetworkRequest

final class TransactionReceiptCell: UITableViewCell, NibRegisterable {

    @IBOutlet weak var receiptLabel: UILabel!
    
    private var fileService: FileService = FileService(serviceRequest: serviceRequest)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        receiptLabel.font = UIFont.appFont(type: .regular, size: 17)
        accessoryType = .disclosureIndicator
    }
    
    func configure(with transactionReceipt: TransactionReceipt) {
        let photoID = transactionReceipt.receiptPhotoID
        guard (try? profileImageStore.getFile(name: photoID)) == nil else { return }
        
        store.privateContext { [weak self] privateContext in
            self?.fileService.getImage(imageName: photoID) { downloadURL, error in
                DispatchQueue.main.async {
                    if let downloadURL = downloadURL {
                        _ = try? profileImageStore.storeFile(at: downloadURL, fileName: photoID)
                    }
                }
            }
        }
    }
    
}
