//
//  FileStore.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 1/5/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CoreData
import Store
import Disk

private let defaultExpirationTimeInterval: TimeInterval = 60 * 60 * 24 * 2

public enum FileStoreError: Error {
    case noContext
    case unableToFetchUser
    case unableToFetchMechanic
}

public class FileStore {
    
    init(folderName: String = "", directory: Disk.Directory, expirationTimeInterval: TimeInterval = defaultExpirationTimeInterval) {
        self.folderName = folderName
        self.directory = directory
        self.expirationTimeInterval = expirationTimeInterval
    }
    
    public let directory: Disk.Directory
    public let expirationTimeInterval: TimeInterval
    
    public func destroy() throws {
        try Disk.remove(folderName, from: directory)
    }
    
    public let folderName: String
    
    public func getFile(name: String, allowExpired: Bool = false) throws -> Data? {
        if let dataHolder = fileCache.object(forKey: name as NSString) {
            return dataHolder.data
        }
        let datedData: DatedData = try Disk.retrieve(folder(with: name), from: directory)
        guard allowExpired == false, datedData.dateFirstStored.timeIntervalSince(Date()) < defaultExpirationTimeInterval else {
            return nil
        }
        return datedData.data
    }
    
    private let fileManager: FileManager = FileManager.default
    
    @discardableResult
    public func storeFile(at url: URL, fileName: String? = nil) throws -> URL {
        let data = try Data(contentsOf: url)
        let name = fileName ?? url.lastPathComponent
        return try storeFile(data: data, fileName: name)
    }
    
    @discardableResult
    public func storeFile(data: Data, fileName: String) throws -> URL {
        let datedData = DatedData(data: data)
        fileCache.setObject(DataHolder(data: data), forKey: fileName as NSString)
        return try Disk.save(datedData, to: directory, as: folder(with: fileName))
    }
    
    private func folder(with fileName: String) -> String {
        return folderName + "/" + fileName
    }
    
    public func getFilePathForFile(withName name: String) -> URL? {
        guard let url = URL(string: folder(with: name)) else { return nil }
        return url
    }
    
//    private func directory() throws -> URL {
//        var documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
//        documentDirectory = documentDirectory.appendingPathComponent(folderName, isDirectory: true)
//        if fileManager.fileExists(atPath: documentDirectory.path) == false {
//            try fileManager.createDirectory(at: documentDirectory, withIntermediateDirectories: true, attributes: nil)
//        }
//        return documentDirectory
//    }
    
}

public struct DatedData: Codable {
    let dateFirstStored: Date
    let data: Data
    
    init(data: Data) {
        self.data = data
        self.dateFirstStored = Date()
    }
}

public class ProfileImageStore: FileStore {
    
    public func getImage(withName name: String) -> UIImage? {
        var fileOptional: Data?
        do {
            fileOptional = try getFile(name: name)
        } catch { return nil }
        guard let data = fileOptional else { return nil }
        return UIImage(data: data)
    }
    
    public func getImage(forUserWithID userID: String, in context: NSManagedObjectContext) -> UIImage? {
        guard let profileImageID = User.fetch(with: userID, in: context)?.profileImageID else {
            return nil
        }
        return getImage(withName: profileImageID)
    }
    
    public func getImage(forMechanicWithID mechanicID: String, in context: NSManagedObjectContext) -> UIImage? {
        guard let profileImageID = Mechanic.fetch(with: mechanicID, in: context)?.profileImageID else {
            return nil
        }
        return getImage(withName: profileImageID)
    }
    
    
    
    @discardableResult
    public func storeFile(at url: URL, userID: String, in context: NSManagedObjectContext) throws -> URL {
        guard let profileImageID = User.fetch(with: userID, in: context)?.profileImageID else {
            throw FileStoreError.unableToFetchUser
        }
        return try storeFile(at: url, fileName: profileImageID)
    }
    
    @discardableResult
    public func storeFile(data: Data, userID: String, in context: NSManagedObjectContext) throws -> URL {
        guard let profileImageID = User.fetch(with: userID, in: context)?.profileImageID else {
            throw FileStoreError.unableToFetchUser
        }
        return try storeFile(data: data, fileName: profileImageID)
    }
    
    @discardableResult
    public func storeFile(at url: URL, mechanicID: String, in context: NSManagedObjectContext) throws -> URL {
        guard let profileImageID = Mechanic.fetch(with: mechanicID, in: context)?.profileImageID else {
            throw FileStoreError.unableToFetchMechanic
        }
        return try storeFile(at: url, fileName: profileImageID)
    }
    
    @discardableResult
    public func storeFile(data: Data, mechanicID: String, in context: NSManagedObjectContext) throws -> URL {
        guard let profileImageID = Mechanic.fetch(with: mechanicID, in: context)?.profileImageID else {
            throw FileStoreError.unableToFetchMechanic
        }
        return try storeFile(data: data, fileName: profileImageID)
    }
    
}

extension User {
    
    public func setProfileImage(withFileURL url: URL) throws {
        guard let context = managedObjectContext else {
            throw FileStoreError.noContext
        }
        try profileImageStore.storeFile(at: url, userID: identifier, in: context)
    }
    
}


public let profileImageStore = ProfileImageStore(folderName: "profile-images", directory: .caches)


public extension Data {
    
    private static let mimeTypeSignatures: [UInt8 : String] = [
        0xFF : "image/jpeg",
        0x89 : "image/png",
        0x47 : "image/gif",
        0x49 : "image/tiff",
        0x4D : "image/tiff",
        0x25 : "application/pdf",
        0xD0 : "application/vnd",
        0x46 : "text/plain",
        ]
    
    enum MimeType: String {
        case jpeg = "image/jpeg"
        case png = "image/png"
        case gif = "image/gif"
        case tiff = "image/tiff"
        case pdf = "application/pdf"
        case vnd = "application/vnd"
        case plainText = "text/plain"
        
        var pathExtension: String {
            switch self {
            case .jpeg: return "jpeg"
            case .png: return "png"
            case .gif: return "gif"
            case .tiff: return "tiff"
            case .pdf: return "pdf"
            case .vnd: return "vnd"
            case .plainText: return "txt"
            }
        }
    }
    
    var mimeType: MimeType? {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        guard let rawValue = Data.mimeTypeSignatures[c] else { return nil }
        return MimeType(rawValue: rawValue)
    }
    
}
