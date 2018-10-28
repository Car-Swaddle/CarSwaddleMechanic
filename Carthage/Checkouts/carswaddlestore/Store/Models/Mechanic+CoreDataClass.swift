//
//  Mechanic+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/30/18.
//
//

import Foundation
import CoreData

@objc(Mechanic)
public final class Mechanic: NSManagedObject, NSManagedObjectFetchable {

    public static func currentLoggedInMechanic(in context: NSManagedObjectContext) -> Mechanic? {
        return User.currentUser(context: context)?.mechanic
    }
    
}
