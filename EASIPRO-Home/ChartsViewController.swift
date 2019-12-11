//
//  ChartsViewController.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 5/2/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//

import UIKit
import SMARTMarkers

class ChartsViewController: InsightsController {

    // Get fhir manager from the appDelegate
    var fhir: FHIRManager! = (UIApplication.shared.delegate as! AppDelegate).fhir
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Trends"
        navigationItem.rightBarButtonItem = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let mainViewController = (self.tabBarController?.viewControllers?.first as! UINavigationController).viewControllers.first as? MainViewController {
            if let data = mainViewController.tasks?.flatMap({ $0.tasks }) {
                self.tasks = data
            }
            
            tableView.reloadData()
        }
    }
}
