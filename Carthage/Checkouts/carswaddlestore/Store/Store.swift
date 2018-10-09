//
//  Store.swift
//  Store
//
//  Created by Kyle Kendall on 9/13/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import CoreData

private let storeName = "CarSwaddleStore"
private let storeExtension = "momd"

public class Store {
    
    private let containerName = "cardSwaddle"
    
    public init() {
        
    }
    
    // MARK: - Core Data stack
    
    lazy private var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: type(of: self))
        let modelURL = bundle.url(forResource: storeName, withExtension: storeExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName, managedObjectModel: managedObjectModel)
        
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    public var mainContext: NSManagedObjectContext {
        assert(Thread.isMainThread, "Must be on main")
        return persistentContainer.viewContext
    }
    
    public func mainContext(_ closure: @escaping (NSManagedObjectContext) -> Void) {
        mainContext.perform {
            closure(self.mainContext)
        }
    }
    
    public func mainContextAndWait(_ closure: @escaping (NSManagedObjectContext) -> Void) {
        mainContext.performAndWait {
            closure(self.mainContext)
        }
    }
    
    public func privateContext(_ closure: @escaping (NSManagedObjectContext)->()) {
        persistentContainer.performBackgroundTask { context in
            closure(context)
        }
    }
    
    public func privateContextAndWait(_ closure: @escaping (NSManagedObjectContext)->()) {
        let context = persistentContainer.newBackgroundContext()
        context.performAndWait {
            closure(context)
        }
    }
    
}


public extension NSManagedObjectContext {
    
    public func persist() {
        guard  hasChanges else { return }
        do {
            try save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
}

