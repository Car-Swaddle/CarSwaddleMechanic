//
//  FileUploadService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 1/5/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation

extension NetworkRequest.Request.Endpoint {
    fileprivate static let upload = Request.Endpoint(rawValue: "/api/data/profile-picture")
    fileprivate static let getImage = Request.Endpoint(rawValue: "/api/data/image/{imageName}")
    fileprivate static let getUserImage = Request.Endpoint(rawValue: "/api/data/profile-picture/{userID}")
}

final public class FileService: Service {
    
    @discardableResult
    public func uploadProfileImage(fileURL: URL, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.multipartFormDataPost(with: .upload) else { return nil }
        try? urlRequest.authenticate()
        let contentType = "image/*"
        return serviceRequest.uploadMultipartFormData(urlRequest: urlRequest, fileURL: fileURL, contentType: contentType) { [weak self] data, response, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getImage(imageName: String, completion: @escaping (_ fileURL: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        guard imageName.isEmpty == false else { return nil }
        guard let path = try? Path(endpoint: .getImage, pathArguments: ["imageName": imageName]) else { return nil }
        guard var urlRequest = serviceRequest.download(withPath: path.path) else { return nil }
        try? urlRequest.authenticate()
        return serviceRequest.download(urlRequest: urlRequest) { downloadedFileURL, response, error in
            completion(downloadedFileURL, error)
        }
    }
    
    @discardableResult
    public func getProfileImage(userID: String, completion: @escaping (_ fileURL: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        guard userID.isEmpty == false else { return nil }
        guard let path = try? Path(endpoint: .getUserImage, pathArguments: ["userID": userID]) else { return nil }
        guard var urlRequest = serviceRequest.download(withPath: path.path) else { return nil }
        try? urlRequest.authenticate()
        return serviceRequest.download(urlRequest: urlRequest) { downloadedFileURL, response, error in
            completion(downloadedFileURL, error)
        }
    }
    
}
