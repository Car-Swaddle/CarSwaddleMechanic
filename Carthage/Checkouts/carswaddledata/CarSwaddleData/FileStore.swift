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

public class FileStore {
    
    init(folderName: String = "") {
        self.folderName = folderName
    }
    
    public func destroy() throws {
        let directory = try self.directory()
        try fileManager.removeItem(at: directory)
    }
    
    public let folderName: String
    
    public func getFile(name: String) throws -> Data? {
        let fileURL = try getFilePath(name: name)
        let data = try Data(contentsOf: fileURL)
        return data
    }
    
    public func getFilePath(name: String) throws -> URL {
        return try directory().appendingPathComponent(name).appendingPathExtension("jpeg")
    }
    
    private let fileManager: FileManager = FileManager.default
    
    @discardableResult
    public func storeFile(url: URL, fileName: String? = nil) throws -> URL {
        let data = try Data(contentsOf: url)
        return try storeFile(data: data, fileName: fileName ?? url.lastPathComponent)
    }
    
    @discardableResult
    public func storeFile(data: Data, fileName: String) throws -> URL {
        let newFileURL = try directory().appendingPathComponent(fileName).appendingPathExtension("jpeg")
        fileManager.createFile(atPath: newFileURL.path, contents: data, attributes: nil)
        try data.write(to: newFileURL)
        return newFileURL
    }
    
    private func directory() throws -> URL {
        var documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        documentDirectory = documentDirectory.appendingPathComponent(folderName, isDirectory: true)
        if fileManager.fileExists(atPath: documentDirectory.path) == false {
            try fileManager.createDirectory(at: documentDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return documentDirectory
    }
    
}

public class ProfileImageStore: FileStore {
    
    public func getImage(withName name: String) -> UIImage? {
        var fileOptional: Data?
        do {
            fileOptional = try getFile(name: name)
        } catch {
            print(error)
            return nil
        }
        guard let file = fileOptional else { return nil }
        return UIImage(data: file)
    }
    
    public func getImage(forUserWithID userID: String) -> UIImage? {
        return getImage(withName: userID)
    }
    
    public func getImage(forMechanicWithID mechanicID: String) -> UIImage? {
        return getImage(withName: mechanicID)
    }
    
    @discardableResult
    public func storeFile(url: URL, userID: String) throws -> URL {
        return try storeFile(url: url, fileName: userID)
    }
    
    @discardableResult
    public func storeFile(data: Data, userID: String) throws -> URL {
        return try storeFile(data: data, fileName: userID)
    }
    
    @discardableResult
    public func storeFile(url: URL, mechanicID: String) throws -> URL {
        return try storeFile(url: url, fileName: mechanicID)
    }
    
    @discardableResult
    public func storeFile(data: Data, mechanicID: String) throws -> URL {
        return try storeFile(data: data, fileName: mechanicID)
    }
    
}

extension User {
    
    public func setProfileImage(withFileURL url: URL) throws {
        try profileImageStore.storeFile(url: url, userID: identifier)
    }
    
}


public let profileImageStore = ProfileImageStore(folderName: "profile-images")


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
