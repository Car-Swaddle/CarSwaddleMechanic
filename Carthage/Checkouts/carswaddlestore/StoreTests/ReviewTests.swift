//
//  ReviewTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 1/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import Store


class ReviewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? store.destroyAllData()
    }
    
    func testCreateReview() {
        let context = store.mainContext
        let review = Review(json: reviewJSON, context: context)
        XCTAssert(review != nil, "Must have region from: \(reviewJSON)")
    }
    
}


private let regionWeirdJSON: [String: Any] = ["longitude": -111.827039492261, "createdAt": "2018-11-13T07:14:14.453Z", "firstName": "Rupert", "radius": 360, "isActive": 1, "updatedAt": "2018-11-13T07:14:14.460Z", "distance": 0, "lastName": "Rolph", "latitude": 40.38754862123388, "id": "5c00fe80-e702-11e8-9a16-6dd8a1b37c0f", "userID": "2e8ec720-e702-11e8-9a16-6dd8a1b37c0f", "phoneNumber": "801-111-1111", "regionID": "28114f80-e716-11e8-bfed-87ccb8fe8373", ]

private let reviewJSON: [String: Any] = [
    "id": "45f279e0-0e42-11e9-834e-458588e04d18",
    "rating": CGFloat(4.2),
    "text": "He also helped me know how to change my oil myself!",
    "reviewerID": "c36fadd0-0e41-11e9-834e-458588e04d18",
    "revieweeID": "ce8b0070-0e41-11e9-834e-458588e04d18",
    "createdAt": "2019-01-02T03:55:41.566Z",
    "updatedAt": "2019-01-02T03:55:41.570Z",
    "userID": "c36fadd0-0e41-11e9-834e-458588e04d18",
    "autoServiceIDFromUser": "31fd6030-0e42-11e9-834e-458588e04d18",
    "autoServiceIDFromMechanic": NSNull(),
    "mechanicID": "ce8b0070-0e41-11e9-834e-458588e04d18",
    "autoServiceFromUser": [
        "id": "31fd6030-0e42-11e9-834e-458588e04d18",
        "scheduledDate": "2018-11-18T17:00:00.000Z",
        "status": "scheduled",
        "notes": NSNull(),
        "createdAt": "2019-01-02T03:55:08.084Z",
        "updatedAt": "2019-01-02T03:55:08.088Z",
        "userID": "c36fadd0-0e41-11e9-834e-458588e04d18",
        "mechanicID": "ce8b0070-0e41-11e9-834e-458588e04d18",
        "vehicleID": "ecb181f0-0e41-11e9-834e-458588e04d18"
    ],
    "autoServiceFromMechanic": NSNull()
]
