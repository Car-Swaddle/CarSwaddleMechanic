//
//  TaxYearCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/10/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import Store
import CoreData
import CoreLocation


let distanceNumberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    
    numberFormatter.minimumIntegerDigits = 1
    numberFormatter.maximumFractionDigits = 0
    
    return numberFormatter
}()

final class TaxYearCell: UITableViewCell, NibRegisterable {
    
    private var taxInfo: TaxInfo?
    
    @IBOutlet private weak var mileDeductTitleLabel: UILabel!
    @IBOutlet private weak var dollarDeductTitleLabel: UILabel!
    @IBOutlet private weak var taxYearTitleLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var deductionCostLabel: UILabel!
    @IBOutlet private weak var milesDeductionLabel: UILabel!
    
    private var taxNetwork: TaxNetwork = TaxNetwork(serviceRequest: serviceRequest)
    private var task: URLSessionDataTask? {
        willSet {
            task?.cancel()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        mileDeductTitleLabel.font = UIFont.appFont(type: .regular, size: 15)
        dollarDeductTitleLabel.font = UIFont.appFont(type: .regular, size: 15)
        taxYearTitleLabel.font = UIFont.appFont(type: .regular, size: 15)
        
        yearLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        deductionCostLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        milesDeductionLabel.font = UIFont.appFont(type: .semiBold, size: 17)
    }
    
    func configure(with taxInfo: TaxInfo, updateData: Bool = true) {
        self.taxInfo = taxInfo
        
        yearLabel.text = taxInfo.year
        
        if updateData {
            requestData()
        }
        
//        if task == nil {
            deductionCostLabel.text = currencyFormatter.string(from: taxInfo.mechanicCostInCents.dollarValue)
            milesDeductionLabel.text = distanceNumberFormatter.string(from: NSNumber(value: taxInfo.milesDriven))
//        } else {
//            deductionCostLabel.text = NSLocalizedString("--", comment: "empty values for cost to deduct")
//            milesDeductionLabel.text = NSLocalizedString("--", comment: "empty values for miles to deduct")
//        }
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        guard let year = self.taxInfo?.year else { return }
        store.privateContext { [weak self] context in
            self?.task = self?.taxNetwork.requestTaxInfo(year: year, in: context) { taxInfoObjectID, error in
            store.mainContext { mainContext in
                self?.task = nil
                if let taxInfoObjectID = taxInfoObjectID,
                    let taxInfo = mainContext.object(with: taxInfoObjectID) as? TaxInfo,
                    taxInfo.year == self?.taxInfo?.year {
                    self?.configure(with: taxInfo, updateData: false)
                }
                completion()
            }
        }
    }
}
    
}


extension TaxInfo {
    
    public var milesDriven: Int {
        return  Int(CLLocationDistance(metersDriven).metersToMiles)
    }
    
}
