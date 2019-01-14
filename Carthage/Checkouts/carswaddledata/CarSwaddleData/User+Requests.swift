//
//  User+Requests.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 11/10/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleNetworkRequest
import CoreData
import Store

public final class UserNetwork: Network {
    
    private var userService: UserService
    private var fileService: FileService
    
    override public init(serviceRequest: Request) {
        self.userService = UserService(serviceRequest: serviceRequest)
        self.fileService = FileService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func update(user: User, in context: NSManagedObjectContext, completion: @escaping (_ userObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return update(firstName: user.firstName, lastName: user.lastName, phoneNumber: user.phoneNumber, token: nil, in: context, completion: completion)
    }
    
    @discardableResult
    public func update(firstName: String?, lastName: String?, phoneNumber: String?, token: String?, in context: NSManagedObjectContext, completion: @escaping (_ userObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return userService.updateCurrentUser(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, token: token) { json, error in
            context.perform {
                var userObjectID: NSManagedObjectID?
                defer {
                    completion(userObjectID, error)
                }
                
                guard let json = json else { return }
                let user = User.fetchOrCreate(json: json, context: context)
                context.persist()
                userObjectID = user?.objectID
            }
        }
    }
    
    
    @discardableResult
    public func requestCurrentUser(in context: NSManagedObjectContext, completion: @escaping (_ userObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return userService.getCurrentUser { json, error in
            context.perform {
                var userObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(userObjectID, error)
                    }
                }
                
                guard let json = json else { return }
                let user = User.fetchOrCreate(json: json, context: context)
                context.persist()
                userObjectID = user?.objectID
            }
        }
    }
    
    @discardableResult
    public func setProfileImage(fileURL: URL, in context: NSManagedObjectContext, completion: @escaping (_ userObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return fileService.uploadProfileImage(fileURL: fileURL) { json, error in
            context.perform {
                var userObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(userObjectID, error)
                    }
                }
                
                if let currentUserID = User.currentUserID {
                    _ = try? profileImageStore.storeFile(url: fileURL, fileName: currentUserID)
                }
                
                guard let currentUser = User.currentUser(context: context), error == nil else { return }
                currentUser.profileImageID = json?["profileImageID"] as? String
                context.persist()
                userObjectID = currentUser.objectID
            }
        }
    }
    
    @discardableResult
    public func getProfileImage(userID: String, completion: @escaping (_ fileURL: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        return fileService.getProfileImage(userID: userID) { url, responseError in
            var completionError: Error? = responseError
            var permanentURL: URL?
            defer {
                completion(permanentURL, completionError)
                
            }
            guard let url = url else { return }
            do {
                permanentURL = try profileImageStore.storeFile(url: url, fileName: userID)
            } catch { completionError = error }
        }
    }
    
    @discardableResult
    public func getImage(imageName: String, completion: @escaping (_ fileURL: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        return fileService.getImage(imageName: imageName) { url, responseError in
            var completionError: Error? = responseError
            var permanentURL: URL?
            defer {
                completion(permanentURL, completionError)
            }
            guard let url = url else { return }
            do {
                permanentURL = try profileImageStore.storeFile(url: url, fileName: imageName)
            } catch {
                completionError = error
            }
        }
    }
    
}
