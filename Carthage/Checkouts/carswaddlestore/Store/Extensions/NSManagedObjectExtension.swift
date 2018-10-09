//
//  NSManagedObjectExtension.swift
//  Store
//
//  Created by Kyle Kendall on 9/16/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import CoreData

public extension NSManagedObject {
    
    public static var entityName: String {
        let fullClassName = NSStringFromClass(self)
        let baseName = fullClassName.components(separatedBy: ".").last
        return baseName ?? fullClassName
    }
    
}
