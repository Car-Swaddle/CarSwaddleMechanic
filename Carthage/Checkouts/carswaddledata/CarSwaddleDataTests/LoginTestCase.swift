//
//  LoginTestCase.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 10/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import CarSwaddleNetworkRequest
import Authentication

class LoginTestCase: XCTestCase {

    let auth = Auth(serviceRequest: serviceRequest)
    
    override func setUp() {
        
        DispatchQueue.once(token: "SomeString") {
            auth.logout {_ in }
        }
        
        loginOrSignUpIfNeeded()
    }
    
    private func loginOrSignUpIfNeeded() {
        guard !auth.isLoggedIn else { return }
        let exp = expectation(description: "The exp")
        
        let context = store.mainContext
        auth.mechanicLogin(email: "k@k.com", password: "password", context: context) { [weak self] error in
            if error == nil {
                exp.fulfill()
            } else {
                self?.auth.mechanicSignUp(email: "k@k.com", password: "password", context: context) { error in
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}



#if targetEnvironment(simulator)
private let domain = "127.0.0.1"
#else
private let domain = "Kyles-MacBook-Pro.local"
#endif

public let serviceRequest: Request = {
    let request = Request(domain: domain)
    request.port = 3000
    request.timeout = 15
    request.defaultScheme = .http
    return request
}()

private let authentication = AuthController()

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) { return }
        _onceTracker.append(token)
        block()
    }
}
