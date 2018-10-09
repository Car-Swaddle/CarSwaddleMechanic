//
//  ServerRequest.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 9/17/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation
import Authentication


#if targetEnvironment(simulator)
    private let domain = "127.0.0.1"
#else
    private let domain = "kkenda2-ml.local"
#endif

public let serverRequest: Request = {
    let request = Request(domain: domain)
    request.port = 3000
    request.timeout = 15
    request.defaultScheme = .http
    return request
}()

let authentication = AuthController()

enum RequestError: Error {
    case couldNotAuthenticate
}

private let authenticationHeader = "Authorization"

extension URLRequest {
    
    mutating func authenticate() throws {
        guard let token = authentication.token else {
            throw RequestError.couldNotAuthenticate
        }
        setValue("Bearer \(token)", forHTTPHeaderField: authenticationHeader)
    }
    
    func send(completion: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return send { data, response, error in
            completion(data, error)
        }
    }
    
    func send(completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = serverRequest.dataTask(with: self, completion: completion)
        task?.resume()
        return task
    }
    
    func download(completion: @escaping (_ url: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        return download { url, response, error in
            completion(url, error)
        }
    }
    
    func download(completion: @escaping (_ url: URL?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        let task = serverRequest.downloadTask(with: self, completion: completion)
        task?.resume()
        return task
    }
    
}

//extension URLSessionDataTask {
//
//    func sendWithAuth() {
//    }
//
//}
