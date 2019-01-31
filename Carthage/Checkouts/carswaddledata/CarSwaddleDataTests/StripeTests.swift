//
//  StripeTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 12/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import Store

class StripeTests: LoginTestCase {
    
    private let stripeNetwork: StripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    
    func testRequestVerification() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { context in
            self.stripeNetwork.updateCurrentUserVerification(in: context) { verification, error in
                XCTAssert(verification != nil, "Should have fields needed")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testDoubleRequestVerification() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { context in
            self.stripeNetwork.updateCurrentUserVerification(in: context) { verification1, error in
                self.stripeNetwork.updateCurrentUserVerification(in: context) { verification2, error in
                    XCTAssert(verification2 != nil, "Should have fields needed")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testRequestBalance() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
            self.stripeNetwork.requestBalance(in: pCtx) { objectID, error in
                store.mainContext{ mCtx in
                    if let objectID = objectID, let balance = mCtx.object(with: objectID) as? Balance {
                        let mechanic = Mechanic.currentLoggedInMechanic(in: mCtx)
                        XCTAssert(mechanic?.balance == balance, "Should have balance")
                    } else {
                        XCTAssert(false, "No balance.")
                    }
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testRequestTransactions() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
            self.stripeNetwork.requestTransaction(in: pCtx) { objectIDs, lastID, hasMore, error in
                store.mainContext{ mCtx in
                    XCTAssert(lastID != nil, "Should have lastID")
                    XCTAssert(objectIDs.count > 0, "Should have objects")
                    var objects: [Transaction] = []
                    for objectID in objectIDs {
                        guard let t = mCtx.object(with: objectID) as? Transaction else { continue }
                        objects.append(t)
                    }
                    XCTAssert(objectIDs.count == objects.count, "Should have objects")
                    
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testRequestTransactionsParams() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
//            self.stripeNetwork.requestTransaction(in: pCtx) { objectIDs, lastID, hasMore, error in
            self.stripeNetwork.requestTransaction(startingAfterID: "hi", payoutID: "hi", limit: 1, in: pCtx)  { objectIDs, lastID, hasMore, error in
                store.mainContext{ mCtx in
//                    XCTAssert(lastID != nil, "Should have lastID")
                    XCTAssert(objectIDs.count == 0, "Should have objects")
                    var objects: [Transaction] = []
                    for objectID in objectIDs {
                        guard let t = mCtx.object(with: objectID) as? Transaction else { continue }
                        objects.append(t)
                    }
                    XCTAssert(objectIDs.count == objects.count, "Should have objects")
                    
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
