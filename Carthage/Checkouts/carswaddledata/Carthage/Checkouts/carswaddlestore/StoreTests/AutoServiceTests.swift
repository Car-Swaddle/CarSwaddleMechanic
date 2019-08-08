//
//  AutoServiceTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 11/18/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
import CoreData
@testable import Store

private let autoServiceMechanicID = "10aaf8a0-ea9f-11e8-a56c-2953c4831dcb"
private let autoServiceUserID = "109fd510-ea9f-11e8-a56c-2953c4831dcb"

class AutoServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? store.destroyAllData()
        
        store.mainContext.persist()
    }
    
    func testCreateFromJSON() {
        let context = store.mainContext
        
        let userJSON: JSONObject = ["id": autoServiceUserID]
        let user = User(json: userJSON, context: context)
        XCTAssert(user != nil, "Should have user")
        
        let mechanicJSON: JSONObject = ["id": autoServiceMechanicID]
        let mechanic = Mechanic(json: mechanicJSON, context: context)
        XCTAssert(mechanic != nil, "Should have mechanic")
        
        let autoService = AutoService(json: json, context: context)
        XCTAssert(autoService != nil, "Should have auto service")
        XCTAssert(autoService?.serviceEntities.count != 0, "Should have service entities")
        XCTAssert(autoService?.serviceEntities.first?.entityType == .oilChange, "Should have service entities")
        XCTAssert(autoService?.vehicle != nil, "Should have service entities")
        XCTAssert(autoService?.location != nil, "Should have service entities")
        XCTAssert(autoService?.mechanic != nil, "Should have service entities")
        XCTAssert(autoService?.scheduledDate != nil, "Should have service entities")
        XCTAssert(autoService?.creator == user, "Should have service entities")
        XCTAssert(autoService?.notes == nil, "Should have service entities")
    }
    
    func testCreateFromCouponJSON() {
        let context = store.mainContext
        
        let userJSON: JSONObject = ["id": "109fd510-ea9f-11e8-a56c-2953c4831dcb"]
        let user = User(json: userJSON, context: context)
        XCTAssert(user != nil, "Should have user")
        
        let mechanicJSON: JSONObject = ["id": "10aaf8a0-ea9f-11e8-a56c-2953c4831dcb"]
        let mechanic = Mechanic(json: mechanicJSON, context: context)
        XCTAssert(mechanic != nil, "Should have mechanic")
        
        let autoService = AutoService(json: couponUpdatesAutoServiceJSON, context: context)
        XCTAssert(autoService != nil, "Should have auto service")
        XCTAssert(autoService?.serviceEntities.count != 0, "Should have service entities")
        XCTAssert(autoService?.serviceEntities.first?.entityType == .oilChange, "Should have service entities")
        XCTAssert(autoService?.vehicle != nil, "Should have service entities")
        XCTAssert(autoService?.location != nil, "Should have service entities")
        XCTAssert(autoService?.mechanic != nil, "Should have service entities")
        XCTAssert(autoService?.scheduledDate != nil, "Should have service entities")
        XCTAssert(autoService?.creator == user, "Should have service entities")
        XCTAssert(autoService?.notes == nil, "Should have service entities")
    }
    
    
    func testCreateFromNewJSON() {
        let context = store.mainContext
        
        let userJSON: JSONObject = ["id": "109fd510-ea9f-11e8-a56c-2953c4831dcb"]
        let user = User(json: userJSON, context: context)
        XCTAssert(user != nil, "Should have user")
        
        let mechanicJSON: JSONObject = ["id": "10aaf8a0-ea9f-11e8-a56c-2953c4831dcb"]
        let mechanic = Mechanic(json: mechanicJSON, context: context)
        XCTAssert(mechanic != nil, "Should have mechanic")
        
        let autoService = AutoService(json: json, context: context)
        XCTAssert(autoService != nil, "It's nil")
        XCTAssert(autoService?.reviewFromUser != nil, "It's nil")
    }
    
    func testCreateAutoServiceFromMultipleJSON() {
        let context = store.mainContext
        
        let userJSON: JSONObject = ["id": "109fd510-ea9f-11e8-a56c-2953c4831dcb"]
        let user = User(json: userJSON, context: context)
        XCTAssert(user != nil, "Should have user")
        
        let mechanicJSON: JSONObject = ["id": "10aaf8a0-ea9f-11e8-a56c-2953c4831dcb"]
        let mechanic = Mechanic(json: mechanicJSON, context: context)
        XCTAssert(mechanic != nil, "Should have mechanic")
        
        let autoService = AutoService(json: multipleAutoServicesJSON, context: context)
        XCTAssert(autoService != nil, "It's nil")
    }
    
}


private let multipleAutoServicesJSON: JSONObject = [
    "id": "d9533210-ed68-11e8-8e07-7b80a5dfaf20",
    "scheduledDate": "2018-11-21T08:38:26.451Z",
    "status": "inProgress",
    "notes": NSNull(),
    "createdAt": "2018-11-21T08:38:41.330Z",
    "updatedAt": "2018-11-21T08:38:41.387Z",
    "userID": "109fd510-ea9f-11e8-a56c-2953c4831dcb",
    "mechanicID": "10aaf8a0-ea9f-11e8-a56c-2953c4831dcb",
    "balanceTransactionID": "somerandomid"
]

private let newJSON: JSONObject = [
    "updatedAt": "2018-11-21T08:47:36.359Z",
    "notes": "<null>",
    "createdAt": "2018-11-21T08:47:36.353Z",
    "status": "inProgress",
    "serviceEntities": [],
    "mechanicID": "10aaf8a0-ea9f-11e8-a56c-2953c4831dcb",
    "location": [
        "autoServiceID": "18396110-ed6a-11e8-8e07-7b80a5dfaf20",
        "createdAt": "2018-11-18T19:24:40.395Z",
        "id": "9849c390-eb67-11e8-8d83-876032d55422",
        "point" : [
            "coordinates": [
                "-111.830118",
                "40.38097000000002"
            ],
            "type": "Point"
        ],
        "streetAddress": NSNull(),
        "updatedAt": "2018-11-21T08:47:36.376Z",
    ], "id": "18396110-ed6a-11e8-8e07-7b80a5dfaf20",
       "scheduledDate": "2018-11-21T08:47:30.015Z",
       "userID": "109fd510-ea9f-11e8-a56c-2953c4831dcb",
       "vehicle": [
        "autoServiceID": "18396110-ed6a-11e8-8e07-7b80a5dfaf20",
        "createdAt": "2018-11-17T20:45:35.462Z",
        "id": "bbb8c060-eaa9-11e8-a56c-2953c4831dcb",
        "licensePlate": "153 UGC",
        "name": "Edge",
        "updatedAt": "2018-11-21T08:47:36.371Z",
        "userID": "109fd510-ea9f-11e8-a56c-2953c4831dcb",
        "vin": NSNull(),
    ]
]

private let json: JSONObject = [
    "id": "37bc7a00-eb75-11e8-a860-bd110592a5e0",
    "scheduledDate": "2018-11-18T17:00:00.000Z",
    "status": "scheduled",
    "notes": NSNull(),
    "createdAt": "2018-11-18T21:02:11.361Z",
    "updatedAt": "2018-11-18T21:02:11.373Z",
    "userID": autoServiceUserID,
    "mechanicID": autoServiceMechanicID,
    "location": [
        "id": "9849c390-eb67-11e8-8d83-876032d55422",
        "point": [
            "type": "Point",
            "coordinates": [
            -111.83011800000003,
            40.38097000000002
            ]
        ],
        "streetAddress": NSNull(),
        "createdAt": "2018-11-18T19:24:40.395Z",
        "updatedAt": "2018-11-18T21:02:11.395Z",
        "autoServiceID": "37bc7a00-eb75-11e8-a860-bd110592a5e0"
    ],
    "serviceEntities": [
        [
            "id": "37c41b20-eb75-11e8-a860-bd110592a5e0",
            "entityType": "OIL_CHANGE",
            "createdAt": "2018-11-18T21:02:11.410Z",
            "updatedAt": "2018-11-18T21:02:11.414Z",
            "autoServiceID": "37bc7a00-eb75-11e8-a860-bd110592a5e0",
            "oilChangeID": "37c330c0-eb75-11e8-a860-bd110592a5e0",
            "oilChange": [
                "id": "37c330c0-eb75-11e8-a860-bd110592a5e0",
                "oilType": "SYNTHETIC",
                "createdAt": "2018-11-18T21:02:11.404Z",
                "updatedAt": "2018-11-18T21:02:11.404Z"
            ]
        ]
    ],
    "reviewFromUser": [
        "createdAt": "2019-02-02T18:05:43.228Z",
        "id": "281cbfc0-2715-11e9-b752-4147be7d783d",
        "mechanic": [
            "id": "27ab2eb1-2714-11e9-b752-4147be7d783d",
        ],
        "rating": CGFloat(5),
        "revieweeID": "27ab2eb1-2714-11e9-b752-4147be7d783d",
        "reviewerID": "0f0cd840-2714-11e9-b752-4147be7d783d",
        "text": "New review",
        "user": [
            "id": "0f0cd840-2714-11e9-b752-4147be7d783d"
        ]
    ],
    "vehicle": [
        "id": "bbb8c060-eaa9-11e8-a56c-2953c4831dcb",
        "licensePlate": "153 UGC",
        "name": "Edge",
        "vin": NSNull(),
        "createdAt": "2018-11-17T20:45:35.462Z",
        "updatedAt": "2018-11-18T21:02:11.389Z",
        "userID": "109fd510-ea9f-11e8-a56c-2953c4831dcb",
        "autoServiceID": "37bc7a00-eb75-11e8-a860-bd110592a5e0"
    ]
]


private let couponUpdatesAutoServiceJSON: [String: Any] = [
    "id": "68fbaa00-a795-11e9-af24-552e5fb63657",
    "scheduledDate": "2019-07-17T16:00:00.000Z",
    "status": "scheduled",
    "transferID": NSNull(),
    "balanceTransactionID": NSNull(),
    "invoiceID": "in_1EwiIaDGwCXJzLurwxQi1lbc",
    "chargeID": "ch_1EwkQVDGwCXJzLurCoxGSap5",
    "refundID": NSNull(),
    "notes": NSNull(),
    "createdAt": "2019-07-16T06:46:16.481Z",
    "updatedAt": "2019-07-16T06:46:16.537Z",
    "userID": autoServiceUserID,
    "mechanicID": autoServiceMechanicID,
    "couponID": "20dolla",
    "vehicleID": "66d47ee0-a782-11e9-891e-bf5e223f0a46",
    "user": [
        "firstName": "Kyle",
        "lastName": "Kendall",
        "id": userID,
        "profileImageID": NSNull(),
        "email": "kyle@carswaddle.com",
        "phoneNumber": "+18019605212",
        "timeZone": "America/Denver"
    ],
    "location": [
        "id": "68f875b0-a795-11e9-af24-552e5fb63657",
        "point": [
            "type": "Point",
            "coordinates": [
            -111.83011800000003,
            40.380970000000026
            ]
        ],
        "streetAddress": "W 8400 N 7150\nLehi UT 84043",
        "createdAt": "2019-07-16T06:46:16.460Z",
        "updatedAt": "2019-07-16T06:46:16.493Z",
        "autoServiceID": "68fbaa00-a795-11e9-af24-552e5fb63657",
        "mechanicID": NSNull()
    ],
    "serviceEntities": [
        [
            "id": "68ff2c70-a795-11e9-af24-552e5fb63657",
            "entityType": "OIL_CHANGE",
            "createdAt": "2019-07-16T06:46:16.504Z",
            "updatedAt": "2019-07-16T06:46:16.508Z",
            "autoServiceID": "68fbaa00-a795-11e9-af24-552e5fb63657",
            "oilChangeID": "68fe6920-a795-11e9-af24-552e5fb63657",
            "oilChange": [
                "id": "68fe6920-a795-11e9-af24-552e5fb63657",
                "oilType": "CONVENTIONAL",
                "createdAt": "2019-07-16T06:46:16.498Z",
                "updatedAt": "2019-07-16T06:46:16.498Z"
            ]
        ]
    ],
    "vehicle": [
        "id": "66d47ee0-a782-11e9-891e-bf5e223f0a46",
        "licensePlate": "153 UGC",
        "name": "Ford Explorer 1996",
        "vin": NSNull(),
        "createdAt": "2019-07-16T04:30:12.431Z",
        "updatedAt": "2019-07-16T04:30:12.431Z",
        "userID": "eaee8570-a6c1-11e9-84f4-dd5b313f5310"
    ],
    "mechanic": [
        "id": mechanicID,
        "isActive": true,
        "stripeAccountID": "acct_1EwMl2Fdb7O8VTd8",
        "identityDocumentID": NSNull(),
        "identityDocumentBackID": NSNull(),
        "dateOfBirth": "1996-07-14T06:00:00.000Z",
        "profileImageID": "a8f02480-a6c1-11e9-84f4-dd5b313f5310",
        "isAllowed": true,
        "hasSetAvailability": true,
        "hasSetServiceRegion": true,
        "createdAt": "2019-07-15T05:29:52.800Z",
        "updatedAt": "2019-07-15T05:31:05.084Z",
        "userID": "9226b520-a6c1-11e9-84f4-dd5b313f5310",
        "user": [
            "firstName": "Mechanic",
            "lastName": "Carswaddle",
            "id": "9226b520-a6c1-11e9-84f4-dd5b313f5310",
            "profileImageID": NSNull(),
            "email": "mechanic@carswaddle.com",
            "phoneNumber": "+18019605212",
            "timeZone": "America/Denver"
        ]
    ],
    "reviewFromUser": NSNull(),
    "reviewFromMechanic": NSNull()
]
