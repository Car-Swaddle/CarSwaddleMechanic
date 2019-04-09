//
//  ArrayExtension.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation


public extension Array {
    
    func safeObject(at index: Int) -> Iterator.Element? {
        guard index < count && index >= 0 else { return nil }
        return self[index]
    }
    
}
