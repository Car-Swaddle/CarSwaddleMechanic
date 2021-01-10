//
//  HourCollectionView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI


protocol TimeSlotCollectionViewDelegate: class {
    func didSelectMinute(minute: Minute, collectionView: TimeSlotCollectionView)
}

class Minute {
    let value: Int
    var isSelected: Bool
    
    var secondOfDay: Int {
        return value * 60
    }
    
    init(value: Int, isSelected: Bool) {
        self.value = value
        self.isSelected = isSelected
    }
}

open class DynamicCollectionView: UICollectionView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
}

final class TimeSlotCollectionView: DynamicCollectionView {
    
    weak var timeSlotDelegate: TimeSlotCollectionViewDelegate?
    
    var minutes: [Minute] = [] {
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
        register(TimeSlotCollectionViewCell.self)
        clipsToBounds = false
    }
    
}

extension TimeSlotCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return minutes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TimeSlotCollectionViewCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(with: minutes[indexPath.row])
        return cell
    }
    
}

extension TimeSlotCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let minue = minutes[indexPath.row]
        timeSlotDelegate?.didSelectMinute(minute: minue, collectionView: self)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let size = collectionView.cellForItem(at: indexPath)?.contentView.systemLayoutSizeFitting(CGSize(width: 25, height: 25), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: .required)
//
//        return size ?? .zero
//    }
    
}
