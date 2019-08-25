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


private let privateContextQueue = DispatchQueue(label: "privateContextQueue", qos: .background)

private let importQueue = DispatchQueue(label: "importQueue", qos: .background)

public class PersistentStore {
    
    public let bundle: Bundle
    public let storeName: String
    public let containerName: String
    
    public init(bundle: Bundle, storeName: String, containerName: String) {
        self.bundle = bundle
        self.storeName = storeName
        self.containerName = containerName
    }
    
    public func destroyAllData() throws {
        guard let url = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url else {
            throw StoreError.noPathToPersistentStore
        }
        try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
        _persistentContainer = nil
        updatePersistentContainer()
    }
    
    // MARK: - Core Data stack
    
    private var modelURL: URL {
        return bundle.url(forResource: storeName, withExtension: modelFileExtension)!
    }
    
    lazy private var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private func updatePersistentContainer() {
        _ = persistentContainer
    }
    
    private var _persistentContainer: NSPersistentContainer?
    
    private var persistentContainer: NSPersistentContainer {
        if let persistentContainer = _persistentContainer {
            return persistentContainer
        }
        let newPersistentContainer = createPersistentContainer()
        self._persistentContainer = newPersistentContainer
        return newPersistentContainer
    }
    
    private func createPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: containerName, managedObjectModel: managedObjectModel)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
    
    public var mainContext: NSManagedObjectContext {
        assert(Thread.isMainThread, "Must be on main")
        return persistentContainer.viewContext
    }
    
    public func mainContext(_ closure: @escaping (NSManagedObjectContext) -> Void) {
        DispatchQueue.main.async {
            self.mainContext.perform {
                closure(self.mainContext)
            }
        }
    }
    
    public func mainContextAndWait(_ closure: @escaping (NSManagedObjectContext) -> Void) {
        if Thread.isMainThread {
            mainContext.performAndWait {
                closure(self.mainContext)
            }
        } else {
            DispatchQueue.main.sync {
                self.mainContext.performAndWait {
                    closure(self.mainContext)
                }
            }
        }
    }
    
    public func privateContext(_ closure: @escaping (NSManagedObjectContext)->()) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            privateContextQueue.async {
                guard let context = self?.createPrivateContext() else { return }
                context.performAndWait {
                    closure(context)
                }
            }
        }
    }
    
    public func privateContextAndWait(_ closure: @escaping (NSManagedObjectContext)->()) {
        dispatchPrecondition(condition: DispatchPredicate.notOnQueue(privateContextQueue))
        privateContextQueue.sync {
            let context = self.createPrivateContext()
            context.performAndWait {
                closure(context)
            }
        }
    }
    
    private func createPrivateContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
}


public extension NSManagedObjectContext {
    
    @discardableResult
    public func persist() -> Bool {
        guard hasChanges else { return false }
        do {
            try save()
            return true
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            return false
        }
    }
    
    public func performOnImportQueue(_ closure: @escaping () -> Void) {
        importQueue.async {
            self.performAndWait {
                closure()
            }
        }
    }
    
}

