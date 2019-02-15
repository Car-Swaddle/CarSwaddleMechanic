//
//  FileTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 2/14/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData

class FileTests: XCTestCase {
    
    func testDestroyFiles() {
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpeg") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        
        let name = "someName"
        
        _ = try? profileImageStore.storeFile(url: fileURL, fileName: name)
        let firstFileData = try? profileImageStore.getFile(name: name)
        
        XCTAssert(firstFileData != nil, "Should not be nil")
        
        try? profileImageStore.destroy()
        
        let file = try? profileImageStore.getFile(name: name)
        
        XCTAssert(file == nil, "Should be nil")
        
        
        
        
    }
    
}
