//
//  MechanicTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 11/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
import Store
@testable import CarSwaddleData
import CarSwaddleNetworkRequest

let atlanticLatitude: Double = 28.237381
let atlanticLongitude: Double = -47.420196
private let externalAccountID: String = "btok_1DmcPxIh8ecz19vMMmHJ2462"

class MechanicTests: LoginTestCase {
    
    private var dob: Date {
        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: nil, year: 1990, month: 11, day: 20, hour: 0)
        return dateComponents.date ?? Date()
    }
    
    let mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    let stripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    
    
    func testGetNearestMechanicsClose() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getNearestMechanics(limit: 10, latitude: testMechanicLatitude, longitude: testMechanicLongitude, maxDistance: 1000, in: context) { mechanicIDs, error in
                
                XCTAssert(mechanicIDs.count > 0, "Should have 1 mechanic, got: \(mechanicIDs.count)")
                
                for mechanicID in mechanicIDs {
                    let mechanic = context.object(with: mechanicID) as? Mechanic
                    XCTAssert(mechanic != nil, "Mechanic is nil, should have gotten a mechanic")
                    XCTAssert(mechanic?.user != nil, "User is nil, should have gotten a user")
                    XCTAssert(mechanic?.serviceRegion != nil, "serviceRegion is nil, should have gotten a serviceRegion")
                }
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let isActive = true
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.update(isActive: isActive, token: "SomeKey", in: context) { mechanicID, error in
                guard let mechanicID = mechanicID else {
                    XCTAssert(false, "Should have mechanicID")
                    return
                }
                
                let mechanic = context.object(with: mechanicID) as? Mechanic
                XCTAssert(mechanic != nil, "Mechanic is nil, should have gotten a mechanic")
                XCTAssert(mechanic?.isActive == isActive, "Should be isActive. is \(mechanic!.isActive) should be \(isActive)")
//                XCTAssert(mechanic?.user != nil, "User is nil, should have gotten a user")
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentMechanicDOBAndAddress() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            let address = Address(context: context)
            address.identifier = "local"
            address.line1 = "1541 N 1300 W St"
            address.postalCode = "84062"
            address.city = "American Fork"
            address.state = "Ut"
            
            context.persist()
            
            self?.mechanicNetwork.update(dateOfBirth: self?.dob, address: address, in: context) { mechanicID, error in
                guard let mechanicID = mechanicID else {
                    XCTAssert(false, "Should have mechanicID")
                    return
                }
                
                let mechanic = context.object(with: mechanicID) as? Mechanic
                XCTAssert(mechanic != nil, "Mechanic is nil, should have gotten a mechanic")
                XCTAssert(mechanic?.address != nil, "Address is nil")
                XCTAssert(mechanic?.dateOfBirth != nil, "Should be not nil")
                
                self?.stripeNetwork.updateCurrentUserVerification(in: context) { verificationObjectID, error in
                    
                    guard let verificationObjectID = verificationObjectID, let verification = context.object(with: verificationObjectID) as? Verification else { return }
//                    XCTAssert(verification.typedFieldsNeeded.contains(.addressLine1) == false, "Should not still need field")
//                    XCTAssert(verification.typedFieldsNeeded.contains(.addressPostalCode) == false, "Should not still need field")
//                    XCTAssert(verification.typedFieldsNeeded.contains(.addressCity) == false, "Should not still need field")
//                    XCTAssert(verification.typedFieldsNeeded.contains(.addressState) == false, "Should not still need field")
//
//                    XCTAssert(verification.typedFieldsNeeded.contains(.birthdayDay) == false, "Should not still need field")
//                    XCTAssert(verification.typedFieldsNeeded.contains(.birthdayMonth) == false, "Should not still need field")
//                    XCTAssert(verification.typedFieldsNeeded.contains(.birthdayYear) == false, "Should not still need field")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentMechanicExternalAccount() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.update(externalAccount: externalAccountID, in: context) { mechanicID, error in
                self?.stripeNetwork.updateCurrentUserVerification(in: context) { verificationObjectID, error in
                    guard let verificationObjectID = verificationObjectID, let verification = context.object(with: verificationObjectID) as? Verification else { return }
//                    XCTAssert(verification.typedFieldsNeeded.contains(.socialSecurityNumberLast4Digits) == false, "Should not still need field")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentMechanicSSNLast4() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.update(socialSecurityNumberLast4: "0000", in: context) { mechanicID, error in
                self?.stripeNetwork.updateCurrentUserVerification(in: context) { verificationObjectID, error in
                    guard let verificationObjectID = verificationObjectID,
                        let verification = context.object(with: verificationObjectID) as? Verification else { return }
//                    XCTAssert(verification.typedFieldsNeeded.contains(.socialSecurityNumberLast4Digits) == false, "Should not still need field")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentMechanicPersonalID() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.update(personalIDNumber: "000000000", in: context) { mechanicID, error in
                self?.stripeNetwork.updateCurrentUserVerification(in: context) { verificationObjectID, error in
                    guard let verificationObjectID = verificationObjectID,
                        let verification = context.object(with: verificationObjectID) as? Verification else { return }
//                    XCTAssert(verification.typedFieldsNeeded.contains(.personalIDNumber) == false, "Should not still need field")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetCurrentMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getCurrentMechanic(in: context) { mechanicID, error in
                guard let mechanicID = mechanicID else {
                    XCTAssert(false, "Should have mechanicID")
                    return
                }
                
                let mechanic = context.object(with: mechanicID) as? Mechanic
                XCTAssert(mechanic != nil, "Mechanic is nil, should have gotten a mechanic")
                XCTAssert(mechanic?.isActive != nil, "Should have isActive.)")
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetNearestMechanicsAtlantic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getNearestMechanics(limit: 10, latitude: atlanticLatitude, longitude: atlanticLongitude, maxDistance: 5000, in: context) { mechanicIDs, error in
                XCTAssert(mechanicIDs.count == 0, "Should have 0 mechanic, got: \(mechanicIDs.count)")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetStats() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let mechanicID = "ce8b0070-0e41-11e9-834e-458588e04d18"
        
        let mechanic = Mechanic(context: store.mainContext)
        mechanic.identifier = mechanicID
        mechanic.isActive = true
        
        store.mainContext.persist()
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getStats(mechanicID: mechanicID, in: context) { mechanicObjectID, error in
                XCTAssert(mechanicObjectID != nil, "Got no mechanic")
                if let id = mechanicObjectID,
                    let mechanic = context.object(with: id) as? Mechanic {
                    XCTAssert(mechanic.stats != nil, "Should have stats")
                } else {
                    XCTAssert(false, "Should have id")
                }
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testPerformanceGetNearestMechanicsAtlantic() {
        measure {
            let exp = expectation(description: "\(#function)\(#line)")
            
            store.privateContext { [weak self] context in
                self?.mechanicNetwork.getNearestMechanics(limit: 10, latitude: atlanticLatitude, longitude: atlanticLongitude, maxDistance: 5000, in: context) { mechanicIDs, error in
                    exp.fulfill()
                }
            }
            
            waitForExpectations(timeout: 40, handler: nil)
        }
    }
    
    func testUploadUserImage() {
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "png") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.setProfileImage(fileURL: fileURL, in: context) { mechanicObjectID, error in
                store.mainContext { mainContext in
                    guard let mechanicObjectID = mechanicObjectID else {
                        XCTAssert(false, "mechanicObjectID doesn't exist")
                        return
                    }
                    let image = profileImageStore.getImage(forMechanicWithID: currentMechanicID, in: store.mainContext)
                    XCTAssert(image != nil, "Should have that image yall")
                    let mechanic = mainContext.object(with: mechanicObjectID) as? Mechanic
                    XCTAssert(mechanic != nil, "User doesn't exist")
                    XCTAssert(mechanic?.profileImageID != nil, "profileImageID doesn't exist")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUploadMechanicIdentityDocument() {
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "png") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.uploadIdentityDocument(fileURL: fileURL, in: context) { mechanicObjectID, error in
                store.mainContext { mainContext in
                    guard let mechanicObjectID = mechanicObjectID else {
                        XCTAssert(false, "mechanicObjectID doesn't exist")
                        return
                    }
//                    let image = profileImageStore.getImage(forMechanicWithID: currentMechanicID)
//                    XCTAssert(image != nil, "Should have that image yall")
                    let mechanic = mainContext.object(with: mechanicObjectID) as? Mechanic
                    XCTAssert(mechanic != nil, "User doesn't exist")
                    XCTAssert(mechanic?.identityDocumentID != nil, "identityDocumentID doesn't exist")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetProfileImage() {
        let mechanicID = currentMechanicID
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getProfileImage(mechanicID: mechanicID, in: context) { url, error in
                store.mainContext { mainContext in
                    let image = profileImageStore.getImage(forMechanicWithID: mechanicID, in: store.mainContext)
                    XCTAssert(image != nil, "Should have that image yall")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetMechanics() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getMechanics(limit: 30, offset: 0, sortType: .descending, in: context) { mechanicIDs, error in
                XCTAssert(mechanicIDs.count > 0, "Should have 1 mechanic, got: \(mechanicIDs.count)")
                
                for mechanicID in mechanicIDs {
                    let mechanic = context.object(with: mechanicID) as? Mechanic
                    XCTAssert(mechanic != nil, "Mechanic is nil, should have gotten a mechanic")
                    XCTAssert(mechanic?.user != nil, "User is nil, should have gotten a user")
//                    XCTAssert(mechanic?.serviceRegion != nil, "serviceRegion is nil, should have gotten a serviceRegion")
                }
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    
    func testUpdateMechanicCorporate() {
        let exp = expectation(description: "\(#function)\(#line)")
        let mechanicID = "39895440-8fd8-11e9-a0b9-ff60380afd50"
        let isAllowed = false
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.updateMechanicCorporate(mechanicID: mechanicID, isAllowed: isAllowed, in: context) { mechanicObjectID, error in
                context.perform {
                    XCTAssert(mechanicObjectID != nil, "Should have a mechanic")
                    let mechanic = (context.object(with: mechanicObjectID!) as! Mechanic)
                    XCTAssert(mechanic.isAllowed == isAllowed, "Should have isAllowed \(isAllowed), got: \(mechanic.isAllowed)")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetOilChangePricing() {
        let exp = expectation(description: "\(#function)\(#line)")
//        let mechanicID = "39895440-8fd8-11e9-a0b9-ff60380afd50"
//        let isAllowed = false
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getOilChangePricingForCurrentMechanic(in: context) { objectID, error in
                context.perform {
                    XCTAssert(objectID != nil, "Should have a mechanic")
                    _ = (context.object(with: objectID!) as! Store.OilChangePricing)
//                    XCTAssert(mechanic.isAllowed == isAllowed, "Should have isAllowed \(isAllowed), got: \(mechanic.isAllowed)")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateOilChangePricing() {
        let exp = expectation(description: "\(#function)\(#line)")
        //        let mechanicID = "39895440-8fd8-11e9-a0b9-ff60380afd50"
        //        let isAllowed = false
        let priceUpdate = OilChangePricingUpdate(conventional: 2000, blend: 2300, synthetic: 2600, highMileage: 2900)
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.updateOilChangePricingForCurrentMechanic(newOilChangePriceUpdate: priceUpdate, in: context) { objectID, error in
                context.perform {
                    XCTAssert(objectID != nil, "Should have a mechanic")
                    let pricing = (context.object(with: objectID!) as! Store.OilChangePricing)
                    //                    XCTAssert(mechanic.isAllowed == isAllowed, "Should have isAllowed \(isAllowed), got: \(mechanic.isAllowed)")
                    XCTAssert(pricing.conventional == priceUpdate.conventional &&
                        pricing.blend == priceUpdate.blend &&
                        pricing.synthetic == priceUpdate.synthetic &&
                        pricing.highMileage == priceUpdate.highMileage, "Should be equal")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
