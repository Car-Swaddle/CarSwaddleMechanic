//
//  DayCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CoreData


protocol DayCellDelegate: class {
    func didDeleteTemplateTimeSpan(_ timespan: TemplateTimeSpan, dayCell: DayCell)
    func didAddTimeSpan(_ timespan: TemplateTimeSpan, dayCell: DayCell)
}

final class DayCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: TimeSlotCollectionView!
    @IBOutlet private weak var button: UIButton!
    
    @IBOutlet private weak var weekDayView: UIView!
    @IBOutlet private weak var weekDayLabel: UILabel!
    
    weak var delegate: DayCellDelegate?
    
    private var weekday: Weekday?
    private var timeSlots: [Int] = Array(stride(from: 0, to: 60*24, by: 15))
    private var timespans: [TemplateTimeSpan] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateButtonCornerRadius()
        clipsToBounds = false
        
        weekDayLabel.font = UIFont.appFont(type: .semiBold, size: 20)
    }
    
    func configure(day: Weekday, timespans: [TemplateTimeSpan]) {
        self.weekday = day
        self.timespans = timespans
        collectionView.timeSlotDelegate = self
        collectionView.minutes = self.minutes(from: timespans)
        layoutIfNeeded()
        updateButtonCornerRadius()
        weekDayLabel.text = day.localizedString
        collectionViewHeightConstraint.constant = collectionView.contentSize.height
    }
        
    private func minutes(from timespans: [TemplateTimeSpan]) -> [Minute] {
        var hours: [Minute] = []
        for slot in timeSlots {
            let isTaken = timespans.contains { timespan -> Bool in
                let minute = timespan.startTime / 60
                return minute == slot
            }
            let hour = Minute(value: slot, isSelected: isTaken)
            hours.append(hour)
        }
        return hours
    }
    
    private func updateButtonCornerRadius() {
//        button.layer.cornerRadius = button.frame.height/2
        weekDayView.layer.cornerRadius = weekDayView.frame.height/2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateButtonCornerRadius()
//        weekDayView.layer.cornerRadius = weekDayView.frame.height/2
    }
    
}

extension DayCell: TimeSlotCollectionViewDelegate {
    
    func didSelectMinute(minute: Minute, collectionView: TimeSlotCollectionView) {
        guard let weekday = weekday, let mechanicID = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.identifier else { return }
        
        if let timespan = TemplateTimeSpan.fetch(from: minute, weekday: weekday, mechanicID: mechanicID) {
            timespans.removeAll { loopTimespan -> Bool in
                return loopTimespan.identifier == timespan.identifier
            }
            store.mainContext.delete(timespan)
            store.mainContext.persist()
            delegate?.didDeleteTemplateTimeSpan(timespan, dayCell: self)
        } else {
            let timespan = TemplateTimeSpan(context: store.mainContext)
            timespan.identifier = UUID().uuidString
            timespan.duration = 15.minutes
            timespan.startTime = Int64(minute.secondOfDay)
            timespan.weekday = weekday
            if let mechanic = Mechanic.currentLoggedInMechanic(in: store.mainContext) {
                timespan.mechanic = mechanic
            }
            timespans.append(timespan)
            store.mainContext.persist()
            delegate?.didAddTimeSpan(timespan, dayCell: self)
        }
        collectionView.minutes = self.minutes(from: timespans)
    }
    
}



extension TemplateTimeSpan {
    
    static func fetch(from minute: Minute, weekday: Weekday, mechanicID: String) -> TemplateTimeSpan? {
        let predicate = NSPredicate(format: "%K == %@ && weekday == %i && %K == %i", #keyPath(TemplateTimeSpan.mechanic.identifier), mechanicID, weekday.rawValue, #keyPath(TemplateTimeSpan.startTime), minute.value * 60)
        let fetchRequest: NSFetchRequest<TemplateTimeSpan> = TemplateTimeSpan.fetchRequest()
        fetchRequest.predicate = predicate
        
        let timeSpans = (try? store.mainContext.fetch(fetchRequest)) ?? []
        return timeSpans.first
    }
    
}
