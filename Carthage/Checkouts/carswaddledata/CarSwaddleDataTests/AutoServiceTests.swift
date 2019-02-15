//
//  AutoServiceTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 11/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import CoreData
import Store
import MapKit

private let defaultMechanicID = "8ba0ded0-febd-11e8-9811-059afcb3ba5e"
private let autoServiceID = "09d3c2c0-3084-11e9-b606-eff43c501111"

class AutoServiceTests: LoginTestCase {
    
    private let autoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private var startDate: Date {
        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: nil, year: 2017, month: 11, day: 22, hour: 0)
        return dateComponents.date ?? Date()
    }
    
    private var scheduledDate: Date {
        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: nil, year: 2018, month: 11, day: 22, hour: 10)
        return dateComponents.date ?? Date()
    }
    
    private var endDate: Date {
        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: nil, year: 2020, month: 12, day: 22, hour: 20)
        return dateComponents.date ?? Date()
    }
    
    func testCreateAutoService() {
        
        let exp = expectation(description: "\(#function)\(#line)")
        let context = store.mainContext
        let autoService = createAutoService(in: context)

        autoServiceNetwork.createAutoService(autoService: autoService, sourceID: "", in: context) { newAutoService, error in
            XCTAssert(newAutoService != nil, "Should have auto service")
            XCTAssert(error == nil, "Should not have error")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAutoServiceDetails() {
        let exp = expectation(description: "\(#function)\(#line)")
        let context = store.mainContext
        
        autoServiceNetwork.getAutoServiceDetails(autoServiceID: autoServiceID, in: context) { autoServiceObjectID, error in
            context.perform {
                if let autoServiceObjectID = autoServiceObjectID {
                    let autoService = context.object(with: autoServiceObjectID) as? AutoService
                    XCTAssert(autoService != nil, "Should have auto service")
                } else {
                    XCTAssert(false, "Should have object id")
                }
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAutoServices() {
        let exp = expectation(description: "\(#function)\(#line)")
        let context = store.mainContext
        let autoService = createAutoService(scheduledDate: scheduledDate, in: context)
        
        autoServiceNetwork.createAutoService(autoService: autoService, sourceID: "", in: context) { newAutoService, error in
            self.autoServiceNetwork.getAutoServices(mechanicID: currentMechanicID, startDate: self.startDate, endDate: self.endDate, filterStatus: [.inProgress, .scheduled, .completed], in: context) { autoServiceIDs, error in
                context.performOnImportQueue {
                    let autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: context)
                    
                    XCTAssert(autoServices.count > 0, "Should have auto services")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAutoServicesSorted() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
            self.autoServiceNetwork.getAutoServices(limit: 10, offset: 0, sortStatus: [.completed, .inProgress], in: pCtx) { autoServiceIDs, error in
                store.mainContext { mCtx in
                    let autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: mCtx)
                    
                    XCTAssert(autoServices.count > 0, "Should have auto services")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAutoServicesCurrentMechanicID() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
            self.autoServiceNetwork.getAutoServices(mechanicID: currentMechanicID, startDate: self.startDate, endDate: self.endDate, filterStatus: [.scheduled, .canceled, .inProgress, .completed], in: pCtx) { autoServiceIDs, error in
                store.mainContext { mCtx in
                    let autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: mCtx)
                    
                    XCTAssert(autoServices.count > 0, "Should have auto services")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 3340, handler: nil)
    }
    
    func testUpdateAutoServiceStatus() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { pCtx in
            let autoService = createAutoService(scheduledDate: self.scheduledDate, in: pCtx)
            self.autoServiceNetwork.createAutoService(autoService: autoService, sourceID: "", in: pCtx) { objectID, error in
                guard let objectID = objectID,
                    let cAuto = pCtx.object(with: objectID) as? AutoService else {
                        XCTAssert(false, "Should have Auto serviec")
                        return
                }
                self.autoServiceNetwork.updateAutoService(autoServiceID: cAuto.identifier, status: .canceled, in: pCtx) { objectID, error in
                    store.mainContext { mCtx in
                        guard let objectID = objectID,
                            let auto = mCtx.object(with: objectID) as? AutoService else {
                            XCTAssert(false, "Should have Auto serviec")
                            return
                        }
                        XCTAssert(auto.status == .canceled, "Should have it yall")
                        exp.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateAutoServiceNotes() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { pCtx in
            let autoService = createAutoService(scheduledDate: self.scheduledDate, in: pCtx)
            self.autoServiceNetwork.createAutoService(autoService: autoService, sourceID: "", in: pCtx) { objectID, error in
                guard let objectID = objectID,
                    let cAuto = pCtx.object(with: objectID) as? AutoService else {
                        XCTAssert(false, "Should have Auto serviec")
                        return
                }
                let newNote = "Here dat there note"
                self.autoServiceNetwork.updateAutoService(autoServiceID: cAuto.identifier, notes: newNote, in: pCtx) { objectID, error in
                    store.mainContext { mCtx in
                        guard let objectID = objectID,
                            let auto = mCtx.object(with: objectID) as? AutoService else {
                                XCTAssert(false, "Should have Auto serviec")
                                return
                        }
                        XCTAssert(auto.notes == newNote, "Should have it yall")
                        exp.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateAutoServiceVehicleID() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { pCtx in
            let autoService = createAutoService(scheduledDate: self.scheduledDate, in: pCtx)
            self.autoServiceNetwork.createAutoService(autoService: autoService, sourceID: "", in: pCtx) { objectID, error in
                guard let objectID = objectID,
                    let cAuto = pCtx.object(with: objectID) as? AutoService else {
                        XCTAssert(false, "Should have Auto serviec")
                        return
                }
                let vehicleID = "b1fa6010-febd-11e8-9811-059afcb3ba5e"
                self.autoServiceNetwork.updateAutoService(autoServiceID: cAuto.identifier, vehicleID: vehicleID, in: pCtx) { objectID, error in
                    store.mainContext { mCtx in
                        guard let objectID = objectID,
                            let auto = mCtx.object(with: objectID) as? AutoService else {
                                XCTAssert(false, "Should have Auto serviec")
                                return
                        }
                        XCTAssert(auto.vehicle?.identifier == vehicleID, "Should have it yall")
                        exp.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateAutoServiceScheduledDate() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { pCtx in
            let autoService = createAutoService(scheduledDate: self.scheduledDate, in: pCtx)
            self.autoServiceNetwork.createAutoService(autoService: autoService, sourceID: "", in: pCtx) { objectID, error in
                guard let objectID = objectID,
                    let cAuto = pCtx.object(with: objectID) as? AutoService else {
                        XCTAssert(false, "Should have Auto serviec")
                        return
                }
//                let vehicleID = "b1fa6010-febd-11e8-9811-059afcb3ba5e"
//                let location = CLLocationCoordinate2D(latitude: -12.234, longitude: 12.456)
                let scheduledDate = Date(timeIntervalSince1970: 4567)
                self.autoServiceNetwork.updateAutoService(autoServiceID: cAuto.identifier, scheduledDate: scheduledDate, in: pCtx) { objectID, error in
                    store.mainContext { mCtx in
                        guard let objectID = objectID,
                            let auto = mCtx.object(with: objectID) as? AutoService else {
                                XCTAssert(false, "Should have Auto serviec")
                                return
                        }
                        XCTAssert(auto.scheduledDate == scheduledDate, "Should have it yall")
                        exp.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateAutoServiceLocation() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { pCtx in
            let autoService = createAutoService(scheduledDate: self.scheduledDate, in: pCtx)
            self.autoServiceNetwork.createAutoService(autoService: autoService, sourceID: "", in: pCtx) { objectID, error in
                guard let objectID = objectID,
                    let cAuto = pCtx.object(with: objectID) as? AutoService else {
                        XCTAssert(false, "Should have Auto serviec")
                        return
                }
                let location = CLLocationCoordinate2D(latitude: -12.234, longitude: 12.456)
                self.autoServiceNetwork.updateAutoService(autoServiceID: cAuto.identifier, location: location, in: pCtx) { objectID, error in
                    store.mainContext { mCtx in
                        guard let objectID = objectID,
                            let auto = mCtx.object(with: objectID) as? AutoService else {
                                XCTAssert(false, "Should have Auto serviec")
                                return
                        }
                        XCTAssert(auto.location?.coordinate.latitude == location.latitude && auto.location?.coordinate.longitude == location.longitude, "Should have it yall")
                        exp.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateAutoServiceMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { pCtx in
            let autoService = createAutoService(scheduledDate: self.scheduledDate, in: pCtx)
            self.autoServiceNetwork.createAutoService(autoService: autoService, sourceID: "", in: pCtx) { objectID, error in
                guard let objectID = objectID,
                    let cAuto = pCtx.object(with: objectID) as? AutoService else {
                        XCTAssert(false, "Should have Auto serviec")
                        return
                }
                self.autoServiceNetwork.updateAutoService(autoServiceID: cAuto.identifier, mechanicID: secondMechanicID, in: pCtx) { objectID, error in
                    store.mainContext { mCtx in
                        guard let objectID = objectID,
                            let auto = mCtx.object(with: objectID) as? AutoService else {
                                XCTAssert(false, "Should have Auto serviec")
                                return
                        }
                        XCTAssert(auto.mechanic?.identifier == secondMechanicID, "Should have it yall")
                        XCTAssert(auto.mechanic?.identifier != mechanicID, "Should have it yall")
                        exp.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testCreateAutoServicePerformance() {
        // This is an example of a performance test case.
        self.measure {
            let exp = expectation(description: "\(#function)\(#line)")
            let context = store.mainContext
            let autoService = createAutoService(in: context)
            autoServiceNetwork.createAutoService(autoService: autoService, sourceID: "", in: context) { newAutoService, error in
                XCTAssert(newAutoService != nil, "Should have auto service")
                XCTAssert(error == nil, "Should not have error")
                exp.fulfill()
            }
            
            waitForExpectations(timeout: 40, handler: nil)
        }
    }

}

private let secondUserID = "ec9a7db0-ff7e-11e8-bd6b-cfe654f39af6"
private let secondMechanicID = "eca37e60-ff7e-11e8-bd6b-cfe654f39af6"


private func createAutoService(scheduledDate: Date = Date(), in context: NSManagedObjectContext) -> AutoService {
    let autoService = AutoService(context: context)
    
    let location = Location(context: context)
    location.latitude = 40.89
    location.longitude = 23.3525
    
    autoService.location = location
    
    let user = User.fetch(with: "SomeID", in: context) ?? User(context: context)
    user.identifier = "6d6a30b0-febd-11e8-9811-059afcb3ba5e"
    user.firstName = "Roopert"
    
    autoService.creator = user
    
    let mechanic = Mechanic.fetch(with: defaultMechanicID, in: context) ?? Mechanic(context: context)
    mechanic.identifier = defaultMechanicID
    
    autoService.mechanic = mechanic
    
    let oilChange = OilChange(context: context)
    oilChange.identifier = UUID().uuidString
    oilChange.oilType = .blend
    
    _ = ServiceEntity(autoService: autoService, oilChange: oilChange, context: context)
    
    let vehicle = Vehicle.fetch(with: "ae222ef0-febd-11e8-9811-059afcb3ba5e", in: context) ?? Vehicle(context: context)
    vehicle.creationDate = Date()
    vehicle.identifier = "ae222ef0-febd-11e8-9811-059afcb3ba5e"
    vehicle.licensePlate = "123 HYG"
    vehicle.name = "That name"
    
    // ["location": ["longitude": -111.85325441868542, "latitude": 40.368154170677535], "vehicleID": "b5e59000-306d-11e9-a7ff-670dac1fb827", "serviceEntities": [["specificService": ["oilType": "CONVENTIONAL"], "entityType": "OIL_CHANGE"]], "mechanicID": "cf268610-2e5f-11e9-937b-f1869ab0c925", "priceID": "ed2c5740-306f-11e9-a7ff-670dac1fb827", "status": "scheduled", "scheduledDate": "2019-02-15T07:00:00.000-0700"]
    
    autoService.vehicle = vehicle
    autoService.status = .inProgress
    autoService.scheduledDate = scheduledDate
    
    return autoService
}
