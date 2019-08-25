//
//  ImageCache.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 8/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation

let fileCache = NSCache<NSString, DataHolder>()


public class DataHolder {
    
    public init(data: Data) {
        self.data = data
    }
    
    let data: Data
}

//
//
//imageCache.setObject(UIImage(), forKey: "userID")
//let g = imageCache.object(forKey: "userID")

