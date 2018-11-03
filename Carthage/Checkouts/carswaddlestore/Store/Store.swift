//
//  Store.swift
//  Store
//
//  Created by Kyle Kendall on 9/13/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import CoreData

public typealias JSONObject = [String: Any]

private let modelFileExtension = "momd"

public class Store {
    
    public let bundle: Bundle
    public let storeName: String
    public let containerName: String
    
    public init(bundle: Bundle, storeName: String, containerName: String) {
        self.bundle = bundle
        self.storeName = storeName
        self.containerName = containerName
    }
    
    // MARK: - Core Data stack
    
    lazy private var managedObjectModel: NSManagedObjectModel = {
        let modelURL = bundle.url(forResource: storeName, withExtension: modelFileExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName, managedObjectModel: managedObjectModel)
        
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
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
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
}

