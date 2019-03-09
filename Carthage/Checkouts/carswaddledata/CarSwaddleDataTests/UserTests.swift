//
//  UserTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 11/10/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
import Store
@testable import CarSwaddleData
import CarSwaddleNetworkRequest


#if targetEnvironment(simulator)
private let domain = "127.0.0.1"
#else
private let domain = "Kyles-MacBook-Pro.local"
#endif

class UserTests: LoginTestCase {
    
    let userNetwork = UserNetwork(serviceRequest: serviceRequest)
    let userService = UserService(serviceRequest: serviceRequest)
    
    func testUpdateUser() {
        
        let firstName = "RupertII"
        let lastName = "RolphII"
        let phoneNumber = "1-801-876-8271"
        
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.userNetwork.update(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, token: nil, timeZone: nil, in: context) { objectID, error in
                store.mainContext { mainContext in
                    guard let objectID = objectID else {
                        XCTAssert(false, "Didn't get objectID")
                        return
                    }
                    let fetchedUser = mainContext.object(with: objectID) as? User
                    XCTAssert(fetchedUser?.firstName == firstName, "First name should be \(firstName), but got: \(String(describing: fetchedUser?.firstName))")
                    XCTAssert(fetchedUser?.lastName == lastName, "Last name should be \(lastName), but got: \(String(describing: fetchedUser?.lastName))")
                    XCTAssert(fetchedUser?.phoneNumber == phoneNumber, "First name should be \(phoneNumber), but got: \(String(describing: fetchedUser?.phoneNumber))")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    
    func testGetCurrentUser() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.userNetwork.requestCurrentUser(in: context) { userObjectID, error in
                store.mainContext { mainContext in
                    guard let userObjectID = userObjectID else {
                        XCTAssert(false, "userID doesn't exist")
                        return
                    }
                    let user = mainContext.object(with: userObjectID) as? User
                    XCTAssert(user != nil, "User doesn't exist")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testResetRequest() {
        
        let u = self.userNetwork
        
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { context in
            u.requestCurrentUser(in: context) { userObjectID, error in
                store.mainContext{ mainContext in
                    guard let userObjectID = userObjectID else {
                        XCTAssert(false, "userID doesn't exist")
                        return
                    }
                    let user = mainContext.object(with: userObjectID) as? User
                    XCTAssert(user != nil, "User doesn't exist")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    
    func testUploadUserImage() {
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpeg") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { [weak self] context in
            self?.userNetwork.setProfileImage(fileURL: fileURL, in: context) { userObjectID, error in
                store.mainContext { mainContext in
                    guard let userObjectID = userObjectID else {
                        XCTAssert(false, "userID doesn't exist")
                        return
                    }
                    
                    let image = profileImageStore.getImage(forUserWithID: currentUserID)
                    XCTAssert(image != nil, "Should have that image yall")
                    let user = mainContext.object(with: userObjectID) as? User
                    XCTAssert(user != nil, "User doesn't exist")
                    XCTAssert(user?.profileImageID != nil, "profileImageID doesn't exist")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetProfileImage() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { [weak self] context in
            self?.userNetwork.getProfileImage(userID: currentUserID) { url, error in
                store.mainContext { mainContext in
                    let image = profileImageStore.getImage(forUserWithID: currentUserID)
                    XCTAssert(image != nil, "Should have that image yall")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    
    // Not really testing this framework, just here for convenience
    func testSendSMS() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        userService.sendSMSVerification { error in
            XCTAssert(error == nil, "Should not have gotten a error")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testVerifySMS() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.userNetwork.verifySMS(withCode: "7199", in: context) { userObjectID, error in
                store.mainContext { mainContext in
                    guard let userObjectID = userObjectID else {
                        XCTAssert(false, "userID doesn't exist")
                        return
                    }
                    let user = mainContext.object(with: userObjectID) as? User
                    XCTAssert(user != nil && user?.isPhoneNumberVerified == true, "User doesn't exist or isPhoneNumberVerified is false")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
