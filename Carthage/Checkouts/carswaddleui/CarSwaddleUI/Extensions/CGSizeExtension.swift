//
//  CGSizeExtension.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit


public extension CGSize {
    
    var aspectRatio: CGFloat {
        guard width != 0 else { return 0 }
        return height / width
    }
    
}
