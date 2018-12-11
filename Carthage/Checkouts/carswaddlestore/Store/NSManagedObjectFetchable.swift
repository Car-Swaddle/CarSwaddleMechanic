//
//  NSManagedObjectFetchable.swift
//  Store
//
//  Created by Kyle Kendall on 9/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//


import CoreData


private let identifierKey: String = "identifier"


public protocol JSONInitable {
    init?(json: JSONObject, context: NSManagedObjectContext)
    static func fetchOrCreate(json: JSONObject, context: NSManagedObjectContext) -> Self?
    func configure(with json: JSONObject) throws
}

extension JSONInitable where Self: NSManagedObjectFetchable, Self: NSManagedObject {
    
    public static func fetchOrCreate(json: JSONObject, context: NSManagedObjectContext) -> Self? {
        if let identifier = (json["id"] as? ID) ?? (json["identifier"] as? ID),
            let fetchedObject = fetch(with: identifier, in: context) {
            try? fetchedObject.configure(with: json)
            return fetchedObject
        } else {
            return Self(json: json, context: context)
        }
    }
    
}


/// Conform to this protocol to get a simple fetch method that will fetch an
/// NSManagedObject with an identifier. Identifier can either be a String, Int64, Int
/// at this time.
public protocol NSManagedObjectFetchable {
    
    /// associated type is used here to constrain the type CVarArg to be String,
    /// Int, Int64 for now in the protocol extensions.
    associatedtype ID: CVarArg
    
    /// to conform to this protocol have NSManagedObject must have identifier as
    /// a property or if it uses different identifier name then set that in identifier
    /// key.
    var identifier: ID { get set }
    
    /// format specifier to be used in NSPredicate.
    static var formatSpecifier: String { get }
    
    
    /// Fetch the NSManagedObject of type that conforms to NSManagedObjectFetachable
    ///
    /// - Parameters:
    ///   - identifier: identifier of the NSManagedObject
    ///   - context: context to be used to fetch the
    /// - Returns: an NSmanagedObject that conforms to this protocol.
    static func fetch(with identifier: ID, in context: NSManagedObjectContext) -> Self?
    
    static func fetchAllObjects(with sortDescriptors: [NSSortDescriptor]?, in context: NSManagedObjectContext) -> [Self]
    
    static func fetchObjects(with identifiers: [ID], sortDescriptors: [NSSortDescriptor]?, in context: NSManagedObjectContext) -> [Self]
    
    static func deleteObjects(in context: NSManagedObjectContext, whileKeeping objects: [Self], fetchLimit: Int)
    
}


public extension NSManagedObjectFetchable where Self: NSManagedObject {
    
    
    /// Performs the fetch on a context with NSFetchRequest. This is only used
    /// inside the protocol extension.
    ///
    /// - Parameters:
    ///   - fetchRequest: fetchRequest to be used to fetch NSManagedObject.
    ///   - context: Context to be used to fetch the NSManagedObject.
    /// - Returns: an NSManagedObject that conforms to this protocol.
    fileprivate static func performFetch(with fetchRequest: NSFetchRequest<Self>, in context: NSManagedObjectContext) -> Self? {
        do {
            let objects = try context.fetch(fetchRequest)
            assert(objects.count < 2, "\(Self.self) should be unique to identifier.")
            return objects.first
        } catch {
            return nil
        }
    }
    
    
    /// Performs the fetch on a context with NSFetchRequest. This is only used inside of the procotol extension.
    ///
    /// - Parameters:
    ///   - fetchRequest: fetchRequest to be used to fetch the NSManagedObjects.
    ///   - context: Context to be used to fetch the NSManagedObject.
    /// - Returns: an Array of NSManagedObject that conforms to this protocol.
    private static func performFetch(with fetchRequest: NSFetchRequest<Self>, in context: NSManagedObjectContext) -> [Self] {
        do {
            return try context.fetch(fetchRequest)
        } catch {
            assert(false, "Failed to fetch \(Self.self).")
            return []
        }
    }
}


public extension NSManagedObjectFetchable where Self: NSManagedObject {
    
    /// Fetch the NSManagedObject of type that conforms to NSManagedObjectFetachable
    ///
    /// - Parameters:
    ///   - identifier: identifier of the NSManagedObject
    ///   - context: context to be used to fetch the
    /// - Returns: an NSManagedObject that conforms to this protocol.
    public static func fetch(with identifier: ID, in context: NSManagedObjectContext) -> Self? {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest(entityName: Self.entityName)
        
        fetchRequest.predicate = NSPredicate(format: "\(identifierKey) == \(Self.formatSpecifier)", identifier)
        fetchRequest.fetchLimit = 2
        return performFetch(with: fetchRequest, in: context)
    }
    
    
    /// Fetches all NSManagedObject of type that conforms to this protocol.
    ///
    /// - Parameters:
    ///   - sortDescriptors: sort descriptor to be used to sort the fetched objects.
    ///   - context: context to be used to fetch the NSManagedObjects.
    /// - Returns: An array of conforming NSManagedObject.
    public static func fetchAllObjects(with sortDescriptors: [NSSortDescriptor]?, in context: NSManagedObjectContext) -> [Self] {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest(entityName: Self.entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        
        return performFetch(with: fetchRequest, in: context)
    }
    
    
    /// Fetches NSManagedObjects with the matching IDs.
    ///
    /// - Parameters:
    ///   - identifiers: identifiers of the NSManagedObject that needs fetched.
    ///   - sortDescriptors: sort descriptor to be used to sort the fetched objects.
    ///   - context: context to be used to fetch the NSManagedObjects.
    /// - Returns: An array of NSManagedObject matching the IDs.
    public static func fetchObjects(with identifiers: [ID], sortDescriptors: [NSSortDescriptor]?, in context: NSManagedObjectContext) -> [Self] {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest(entityName: Self.entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = NSPredicate(format: "\(identifierKey) in \(Self.formatSpecifier)", identifiers)
        
        return performFetch(with: fetchRequest, in: context)
    }
    
    /// Fetch objects from their object ids.
    ///
    /// - Parameters:
    ///   - objectIDs: <#objectIDs description#>
    ///   - context: <#context description#>
    /// - Returns: <#return value description#>
    public static func fetchObjects(with objectIDs: [NSManagedObjectID], in context: NSManagedObjectContext) -> [Self] {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest(entityName: Self.entityName)
        fetchRequest.predicate = NSPredicate(format: "Self in %@", objectIDs)
        
        return performFetch(with: fetchRequest, in: context)
    }
    
    
    /// Given a context, holding managed objects, you can pass a subset of managed objects belonging to the given context
    /// and this function will `delete` any managed objects that is not part of the passed in subset of managed objects.
    ///
    /// - Parameters:
    ///   - context: context owning the managed objects
    ///   - objects: array of managed objects to keep. These will not be deleted from the context.
    ///   - fetchLimit: affects memory behaviour. Autoreleasepool will release at least every `fetchLimit`
    public static func deleteObjects(in context: NSManagedObjectContext, whileKeeping objects: [Self], fetchLimit: Int) {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest(entityName: Self.entityName)
        fetchRequest.predicate = NSPredicate(format: "NOT (SELF IN %@)", objects)
        fetchRequest.fetchLimit = fetchLimit
        
        var resultCount: Int = 0
        autoreleasepool {
            do {
                let results = try context.fetch(fetchRequest)
                
                resultCount = results.count
                results.forEach { context.delete($0) }
            }
            catch {
                print("couldn't fetch")
            }
        }
        
        guard resultCount != 0 else { return }
        
        // recursive…
        deleteObjects(in: context, whileKeeping: objects, fetchLimit: fetchLimit)
    }
}

public extension NSManagedObjectFetchable where Self: NSManagedObject, ID == String {
    /// Format specifier for String
    static var formatSpecifier: String { return "%@" }
}

public extension NSManagedObjectFetchable where Self: NSManagedObject, ID == Int64 {
    /// Format specifier for Int64
    static var formatSpecifier: String { return "%d" }
}

public extension NSManagedObjectFetchable where Self: NSManagedObject, ID == Int {
    /// Format specifier for Int
    static var formatSpecifier: String { return "%d" }
}


extension Dictionary where Key == String, Value == Any {
    
    var identifier: String? {
        return (self["id"] as? String) ?? self["identifier"] as? String
    }
    
}

