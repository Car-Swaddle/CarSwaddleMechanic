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

private let defaultMechanicID = "78b58a90-fab8-11e8-93aa-8b803499fdeb"

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

        autoServiceNetwork.createAutoService(autoService: autoService, in: context) { newAutoService, error in
            XCTAssert(newAutoService != nil, "Should have auto service")
            XCTAssert(error == nil, "Should not have error")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAutoServices() {
        let exp = expectation(description: "\(#function)\(#line)")
        let context = store.mainContext
        let autoService = createAutoService(scheduledDate: scheduledDate, in: context)
        
        autoServiceNetwork.createAutoService(autoService: autoService, in: context) { newAutoService, error in
            self.autoServiceNetwork.getAutoServices(mechanicID: defaultMechanicID, startDate: self.startDate, endDate: self.endDate, filterStatus: [.inProgress, .scheduled, .completed], in: context) { autoServiceIDs, error in
                context.perform {
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
//        let context = store.mainContext
        
        store.privateContext { pCtx in
//            let autoService = createAutoService(scheduledDate: self.scheduledDate, in: pCtx)
            
//        autoServiceNetwork.createAutoService(autoService: autoService, in: context) { newAutoService, error in
            self.autoServiceNetwork.getAutoServices(limit: 10, offset: 0, sortStatus: [.completed, .inProgress], in: pCtx) { autoServiceIDs, error in
                store.mainContext { mCtx in
                    let autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: mCtx)
                    
                    XCTAssert(autoServices.count > 0, "Should have auto services")
                    exp.fulfill()
                }
            }
//        }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testCreateAutoServicePerformance() {
        // This is an example of a performance test case.
        self.measure {
            let exp = expectation(description: "\(#function)\(#line)")
            let context = store.mainContext
            let autoService = createAutoService(in: context)
            autoServiceNetwork.createAutoService(autoService: autoService, in: context) { newAutoService, error in
                XCTAssert(newAutoService != nil, "Should have auto service")
                XCTAssert(error == nil, "Should not have error")
                exp.fulfill()
            }
            
            waitForExpectations(timeout: 40, handler: nil)
        }
    }

}


private func createAutoService(scheduledDate: Date = Date(), in context: NSManagedObjectContext) -> AutoService {
    let autoService = AutoService(context: context)
    
    let location = Location(context: context)
//    location.identifier = "9849c390-eb67-11e8-8d83-876032d55422"
    location.latitude = 40.89
    location.longitude = 23.3525
    
    autoService.location = location
    
    let user = User.fetch(with: "SomeID", in: context) ?? User(context: context)
    user.identifier = "SomeID"
    user.firstName = "Roopert"
    
    autoService.creator = user
    
    let mechanic = Mechanic.fetch(with: defaultMechanicID, in: context) ?? Mechanic(context: context)
    mechanic.identifier = defaultMechanicID
    
    autoService.mechanic = mechanic
    
    let oilChange = OilChange(context: context)
    oilChange.identifier = "oil cha"
    oilChange.oilType = .blend
    
    _ = ServiceEntity(autoService: autoService, oilChange: oilChange, context: context)
    
    let vehicle = Vehicle(context: context)
    vehicle.creationDate = Date()
    vehicle.identifier = "9d8c53a0-f91c-11e8-b2ab-8533c1c85021"
    vehicle.licensePlate = "123 HYG"
    vehicle.name = "That name"
    
    autoService.vehicle = vehicle
    autoService.status = .inProgress
    autoService.scheduledDate = scheduledDate
    
    return autoService
}
