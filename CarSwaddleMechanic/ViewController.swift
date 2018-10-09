//
//  ViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/5/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Authentication
import CarSwaddleNetworkRequest
import CarSwaddleUI
import Store

class ViewController: UIViewController {

    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.mainContext.persist()
        
        let user = User(context: store.mainContext)
        user.identifier = "1234567"
        user.firstName = "Rupert"
        user.lastName = "Son"
        user.phoneNumber = "8909871"
        
        store.mainContext.persist()
        
    }


}

