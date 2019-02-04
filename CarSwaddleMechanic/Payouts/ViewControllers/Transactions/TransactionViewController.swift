//
//  TransactionViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store

final class TransactionViewController: UIViewController, StoryboardInstantiating {

    static func create(transaction: Transaction) -> TransactionViewController {
        let viewController = TransactionViewController.viewControllerFromStoryboard()
        viewController.transaction = transaction
        return viewController
    }
    
    private var transaction: Transaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
}
