//
//  HourCollectionView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI


protocol HourCollectionViewDelegate: class {
    func didSelectHour(hour: Hour, collectionView: HourCollectionView)
}

class Hour {
    let value: Int
    var isSelected: Bool
    
    init(value: Int, isSelected: Bool) {
        self.value = value
        self.isSelected = isSelected
    }
}

private let numberOfHours: Int = 24

final class HourCollectionView: UICollectionView {
    
    weak var hourDelegate: HourCollectionViewDelegate?
    
    var hours: [Hour] = [] {
        didSet {
            reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        dataSource = self
        allowsMultipleSelection = true
        (collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        register(HourCollectionViewCell.self)
    }
    
}

extension HourCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HourCollectionViewCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(with: hours[indexPath.row])
        return cell
    }
    
}

extension HourCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let hour = hours[indexPath.row]
        hourDelegate?.didSelectHour(hour: hour, collectionView: self)
//        print("selected item: \(indexPath)")
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let size = collectionView.cellForItem(at: indexPath)?.contentView.systemLayoutSizeFitting(CGSize(width: 25, height: 25), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: .required)
//
//        return size ?? .zero
//    }
    
}
