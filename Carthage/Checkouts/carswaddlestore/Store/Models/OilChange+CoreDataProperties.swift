//
//  OilChange+CoreDataProperties.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData


public enum OilType: String, CaseIterable {
    case conventional = "CONVENTIONAL"
    case blend = "BLEND"
    case synthetic = "SYNTHETIC"
    
    public var localizedString: String {
        switch self {
        case .conventional:
            return NSLocalizedString("Conventional", comment: "Oil type")
        case .blend:
            return NSLocalizedString("Blend", comment: "Oil type")
        case .synthetic:
            return NSLocalizedString("Synthetic", comment: "Oil type")
        }
    }
    
}

extension OilChange {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OilChange> {
        return NSFetchRequest<OilChange>(entityName: OilChange.entityName)
    }
    
    @NSManaged public var identifier: String
    @NSManaged public var serviceEntity: ServiceEntity

}
