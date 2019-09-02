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
import Store


public var currentMechanicID: String = ""
public var currentUserID: String = ""

private let email = "kyle@carswaddle.com"
private let password = "password"

class LoginTestCase: XCTestCase {

    let auth = Auth(serviceRequest: serviceRequest)
    
    override func setUp() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        DispatchQueue.once(token: "SomeString") {
            try? store.destroyAllData()
            auth.logout(deviceToken: nil) { _ in
                DispatchQueue.main.async {
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
        
        loginOrSignUpIfNeeded()
    }
    
    private func loginOrSignUpIfNeeded() {
        guard !auth.isLoggedIn else { return }
        let exp = expectation(description: "The exp")
        
        let context = store.mainContext
        auth.mechanicLogin(email: email, password: password, context: context) { [weak self] error in
            if error == nil {
                currentMechanicID = Mechanic.currentMechanicID ?? ""
                currentUserID = User.currentUserID ?? ""
                exp.fulfill()
            } else {
                self?.auth.mechanicSignUp(email: email, password: password, context: context) { error in
                    currentMechanicID = Mechanic.currentMechanicID ?? ""
                    currentUserID = User.currentUserID ?? ""
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}


#if targetEnvironment(simulator)
private let localDomain = "127.0.0.1"
private let marksLocalDomain = "127.0.0.1"
#else
private let localDomain = "Kyles-MacBook-Pro.local"
private let marksLocalDomain = "msg-macbook.local"
#endif

//private let productionDomain = "api.carswaddle.com"
private let stagingDomain = "api.staging.carswaddle.com"

private var useLocalDomain = false

public let serviceRequest: Request = {
    if useLocalDomain {
        let request = Request(domain: localDomain)
        request.port = 3000
        request.timeout = 15
        request.defaultScheme = .http
        return request
    } else {
        let request = Request(domain: stagingDomain)
//        request.port = 3000
        request.timeout = 15
        request.defaultScheme = .https
        return request
    }
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
