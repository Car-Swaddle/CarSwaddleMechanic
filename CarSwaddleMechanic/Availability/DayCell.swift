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
    @IBOutlet private weak var collectionView: HourCollectionView!
    @IBOutlet private weak var button: UIButton!
    
    weak var delegate: DayCellDelegate?
    
    private var weekday: Weekday?
    
    private var timeSlots: [Int] = [0,1,2,3,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23]
    
    private var timespans: [TemplateTimeSpan] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateButtonCornerRadius()
    }
    
    func configure(day: Weekday, timespans: [TemplateTimeSpan]) {
        self.weekday = day
        self.timespans = timespans
        collectionView.hourDelegate = self
        collectionView.hours = self.hours(from: timespans)
        layoutIfNeeded()
        updateButtonCornerRadius()
        button.setTitle(day.localizedString, for: .normal)
        collectionViewHeightConstraint.constant = collectionView.contentSize.height
    }
    
//    private static var calendar = Calendar(identifier: .gregorian)
    
    private func hours(from timespans: [TemplateTimeSpan]) -> [Hour] {
        var hours: [Hour] = []
        for slot in timeSlots {
            let isThere = timespans.contains { timespan -> Bool in
                let hour = timespan.startTime / 3600
                return hour == slot
            }
            let hour = Hour(value: slot, isSelected: isThere)
            hours.append(hour)
        }
        return hours
    }
    
    private func updateButtonCornerRadius() {
        button.layer.cornerRadius = button.frame.height/2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateButtonCornerRadius()
//        collectionViewHeightConstraint.constant = collectionView.contentSize.height
    }
    
}

extension DayCell: HourCollectionViewDelegate {
    
    func didSelectHour(hour: Hour, collectionView: HourCollectionView) {
        guard let weekday = weekday, let mechanicID = User.currentUser(context: store.mainContext)?.mechanic?.identifier else { return }
        
        if let timespan = TemplateTimeSpan.fetch(from: hour, weekday: weekday, mechanicID: mechanicID) {
            timespans.removeAll { loopTimespan -> Bool in
                return loopTimespan.identifier == timespan.identifier
            }
            store.mainContext.delete(timespan)
            store.mainContext.persist()
            delegate?.didDeleteTemplateTimeSpan(timespan, dayCell: self)
        } else {
            let timespan = TemplateTimeSpan(context: store.mainContext)
            timespan.identifier = UUID().uuidString
            timespan.duration = .hour
            timespan.startTime = Int64(hour.value * 3600)
            timespan.weekday = weekday
            if let mechanic = Mechanic.currentLoggedInMechanic(in: store.mainContext) {
                timespan.mechanic = mechanic
            }
            timespans.append(timespan)
            store.mainContext.persist()
            delegate?.didAddTimeSpan(timespan, dayCell: self)
        }
        collectionView.hours = self.hours(from: timespans)
    }
    
}



extension TemplateTimeSpan {
    
    static func fetch(from hour: Hour, weekday: Weekday, mechanicID: String) -> TemplateTimeSpan? {
        let predicate = NSPredicate(format: "%K == %@ && weekday == %i && %K == %i", #keyPath(TemplateTimeSpan.mechanic.identifier), mechanicID, weekday.rawValue, #keyPath(TemplateTimeSpan.startTime), hour.value * 3600)
        let fetchRequest: NSFetchRequest<TemplateTimeSpan> = TemplateTimeSpan.fetchRequest()
        fetchRequest.predicate = predicate
        
        let timeSpans = (try? store.mainContext.fetch(fetchRequest)) ?? []
        return timeSpans.first
    }
    
}


extension Weekday {
    
    var localizedString: String {
        switch self {
        case .sunday: return NSLocalizedString("Sunday", comment: "Day of the week")
        case .monday: return NSLocalizedString("Monday", comment: "Day of the week")
        case .tuesday: return NSLocalizedString("Tuesday", comment: "Day of the week")
        case .wednesday: return NSLocalizedString("Wednesday", comment: "Day of the week")
        case .thursday: return NSLocalizedString("Thursday", comment: "Day of the week")
        case .friday: return NSLocalizedString("Friday", comment: "Day of the week")
        case .saturday: return NSLocalizedString("Saturday", comment: "Day of the week")
        }
    }
    
}
