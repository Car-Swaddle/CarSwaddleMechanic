//
//  FileServiceTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 1/5/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest


class FileServiceTests: CarSwaddleLoginTestCase {
    
    let fileService = FileService(serviceRequest: serviceRequest)
    
    func testUploadFile() {
        let exp = expectation(description: "\(#function)\(#line)")
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpeg") else {
            XCTAssert(false, "Should have file: image.jpeg in test bundle")
            return
        }
        
        fileService.uploadProfileImage(fileURL: fileURL) { json, error in
            XCTAssert(error == nil, "Should have no error")
            if let json = json {
                XCTAssert((json["profileImageID"] as? String) != nil, "Should have name from json")
            } else {
                XCTAssert(false, "Should have json")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetProfileImage() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        fileService.getProfileImage(userID: currentUserID) { fileURL, error in
            XCTAssert(error == nil, "Should have no error")
            if let fileURL = fileURL {
                let file = try? Data(contentsOf: fileURL)
                XCTAssert(file != nil, "Should have file")
            } else {
                XCTAssert(false, "Should have fileURL")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUploadAndDownloadFile() {
        let exp = expectation(description: "\(#function)\(#line)")
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "smallImage", withExtension: "png") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        
        fileService.uploadProfileImage(fileURL: fileURL) { json, error in
            XCTAssert(error == nil, "Should have no error")
            if let json = json {
                XCTAssert((json["profileImageID"] as? String) != nil, "Should have name from json")
            } else {
                XCTAssert(false, "Should have json")
            }
            
            self.fileService.getProfileImage(userID: currentUserID) { downloadFileURL, error in
                XCTAssert(error == nil, "Should have no error")
                if let downloadFileURL = downloadFileURL {
                    let file = try? Data(contentsOf: downloadFileURL)
                    XCTAssert(file != nil, "Should have file")
                } else {
                    XCTAssert(false, "Should have fileURL")
                }
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }

    
    func testUploadMechanicFile() {
        let exp = expectation(description: "\(#function)\(#line)")
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpeg") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        
        fileService.uploadMechanicProfileImage(fileURL: fileURL) { json, error in
            XCTAssert(error == nil, "Should have no error")
            if let json = json {
                XCTAssert((json["profileImageID"] as? String) != nil, "Should have name from json")
            } else {
                XCTAssert(false, "Should have json")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUploadMechanicIdentityFile() {
        let exp = expectation(description: "\(#function)\(#line)")
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpeg") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        
        fileService.uploadMechanicIdentityDocument(fileURL: fileURL, side: "back") { json, error in
            XCTAssert(error == nil, "Should have no error")
        
            if let json = json {
                XCTAssert((json["identityDocumentID"] as? String) != nil, "Should have name from json")
            } else {
                XCTAssert(false, "Should have json")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetProfileImageMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        fileService.getMechanicProfileImage(mechanicID: currentMechanicID) { fileURL, error in
            XCTAssert(error == nil, "Should have no error")
            if let fileURL = fileURL {
                let file = try? Data(contentsOf: fileURL)
                XCTAssert(file != nil, "Should have file")
            } else {
                XCTAssert(false, "Should have fileURL")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUploadAndDownloadFileMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "smallImage", withExtension: "png") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        
        fileService.uploadMechanicProfileImage(fileURL: fileURL) { json, error in
            XCTAssert(error == nil, "Should have no error")
            if let json = json {
                XCTAssert((json["profileImageID"] as? String) != nil, "Should have name from json")
            } else {
                XCTAssert(false, "Should have json")
            }
            
            self.fileService.getMechanicProfileImage(mechanicID: currentMechanicID) { downloadFileURL, error in
                XCTAssert(error == nil, "Should have no error")
                if let downloadFileURL = downloadFileURL {
                    let file = try? Data(contentsOf: downloadFileURL)
                    XCTAssert(file != nil, "Should have file")
                } else {
                    XCTAssert(false, "Should have fileURL")
                }
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUploadTransactionReceiptFile() {
        let exp = expectation(description: "\(#function)\(#line)")
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "smallImage", withExtension: "png") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        
        fileService.uploadTransactionReceipt(transactionID: transactionID, fileURL: fileURL) { json, error in
            XCTAssert(json?["id"] != nil, "Should have id")
            XCTAssert(json?["receiptPhotoID"] != nil, "Should have photoID")
            
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUploadTransactionReceiptFileAndDownload() {
        let exp = expectation(description: "\(#function)\(#line)")
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "smallImage", withExtension: "png") else {
            XCTAssert(false, "Should have file: image.png in test bundle")
            return
        }
        
        fileService.uploadTransactionReceipt(transactionID: transactionID, fileURL: fileURL) { json, error in
            XCTAssert(json?["id"] != nil, "Should have id")
            XCTAssert(json?["receiptPhotoID"] != nil, "Should have photoID")
            
            if let imageName = json?["receiptPhotoID"] as? String {
                self.fileService.getImage(imageName: imageName) { downloadFileURL, error in
                    XCTAssert(error == nil, "Should have no error")
                    if let downloadFileURL = downloadFileURL {
                        let file = try? Data(contentsOf: downloadFileURL)
                        XCTAssert(file != nil, "Should have file")
                    } else {
                        XCTAssert(false, "Should have fileURL")
                    }
                    exp.fulfill()
                }
            } else {
                XCTAssert(false, "Should have file")
                exp.fulfill()
            }
            
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
