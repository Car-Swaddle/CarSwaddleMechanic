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

class UserTests: LoginTestCase {
    
    let userNetwork = UserNetwork(serviceRequest: serviceRequest)
    
    func testUpdateUser() {
        
        let firstName = "RupertII"
        let lastName = "RolphII"
        let phoneNumber = "1-801-876-8271"
        
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.userNetwork.update(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, in: context) { objectID, error in
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
    
}
