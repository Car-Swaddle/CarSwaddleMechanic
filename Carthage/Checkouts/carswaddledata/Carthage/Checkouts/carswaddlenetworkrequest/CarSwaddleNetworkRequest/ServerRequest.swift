//
//  ServerRequest.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 9/17/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation
import Authentication


//#if targetEnvironment(simulator)
//    private let domain = "127.0.0.1"
//#else
//    private let domain = "Kyles-MacBook-Pro.local"
//#endif

//public let serverRequest: Request = {
//    let request = Request(domain: domain)
//    request.port = 3000
////    request.port = 20125
//    request.timeout = 15
//    request.defaultScheme = .http
//    return request
//}()

private let authentication = AuthController()

public enum RequestError: Error {
    case couldNotAuthenticate
}

public struct UnsuccessfulStatusCode: Error {
    public let statusCode: Int
    public let localizedDescription: String
}

private let authenticationHeader = "Authorization"

extension URLRequest {
    
    mutating func authenticate() throws {
        guard let token = authentication.token else {
            throw RequestError.couldNotAuthenticate
        }
        setValue("Bearer \(token)", forHTTPHeaderField: authenticationHeader)
    }
    
}


extension Request {
    
    func send(urlRequest: URLRequest, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return send(urlRequest: urlRequest) { data, response, error in
            guard let response = response else {
                completion(data, error)
                return
            }
            if response.statusCode >= 200 && response.statusCode < 300 {
                completion(data, error)
            } else {
                let statusCodeError = UnsuccessfulStatusCode(statusCode: response.statusCode, localizedDescription: "Error status code: \(response.statusCode)")
                completion(data, error ?? statusCodeError)
            }
        }
    }
    
    func send(urlRequest: URLRequest, completion: @escaping (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = self.dataTask(with: urlRequest, completion: completion)
        task?.resume()
        return task
    }
    
    func download(urlRequest: URLRequest, completion: @escaping (_ url: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        return download(urlRequest: urlRequest) { url, response, error in
            guard let response = response else {
                completion(url, error)
                return
            }
            if response.statusCode >= 200 && response.statusCode < 300 {
                completion(url, error)
            } else {
                let statusCodeError = UnsuccessfulStatusCode(statusCode: response.statusCode, localizedDescription: "Error status code: \(response.statusCode)")
                completion(url, error ?? statusCodeError)
            }
        }
    }
    
    func download(urlRequest: URLRequest, completion: @escaping (_ url: URL?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        let task = self.downloadTask(with: urlRequest, completion: completion)
        task?.resume()
        return task
    }
    
}
