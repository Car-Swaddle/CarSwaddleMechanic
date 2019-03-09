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

let transactionID = "txn_1DzuNcEUGV6ByO73IAFoguV7"

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
            self.stripeNetwork.requestTransactions(in: pCtx) { objectIDs, lastID, hasMore, error in
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
    
    func testRequestTransactionDetails() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
            self.stripeNetwork.requestTransactionDetails(transactionID: transactionID, in: pCtx) { transactionObjectID, error in
                store.mainContext { mCtx in
                    XCTAssert(transactionObjectID != nil, "Should have objectID")
                    XCTAssert(error == nil, "Should have error")
                    
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateTransactionDetails() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
            self.stripeNetwork.updateTransactionDetails(transactionID: transactionID, mechanicCostCents: 12, drivingDistanceMeters: nil, in: pCtx)  { transactionObjectID, error in
                store.mainContext { mCtx in
                    XCTAssert(transactionObjectID != nil, "Should have objectID")
                    XCTAssert(error == nil, "Should have error")
                    
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUploadTransactionReceiptPhoto() {
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpeg") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
            self.stripeNetwork.uploadTransactionReceipt(transactionID: transactionID, fileURL: fileURL, in: pCtx) { transactionReceiptObjectID, error in
                store.mainContext { mCtx in
                    XCTAssert(transactionReceiptObjectID != nil, "Should have objectID")
                    XCTAssert(error == nil, "Should have error")
                    
                    if let transactionReceiptObjectID = transactionReceiptObjectID,
                        let receipt = mCtx.object(with: transactionReceiptObjectID) as? TransactionReceipt {
                        let file = profileImageStore.getImage(withName: receipt.receiptPhotoID)
                        XCTAssert(file != nil, "File is nil")
                    } else {
                        XCTAssert(false, "Should have receipt")
                    }
                    
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testRequestTransactionsParams() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
            self.stripeNetwork.requestTransactions(startingAfterID: "hi", payoutID: "hi", limit: 1, in: pCtx)  { objectIDs, lastID, hasMore, error in
                store.mainContext{ mCtx in
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
    
    func testRequestBankAccount() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
            self.stripeNetwork.requestBankAccount(in: pCtx) { objectID, error in
                store.mainContext { mCtx in
                    XCTAssert(objectID != nil, "Should have objectID")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
