//
//  Extensions.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 11/26/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showMsg(msg: String) {
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: "Patient App", message: msg, preferredStyle: .alert)
        alertViewController.addAction(alertAction)
        present(alertViewController, animated: true, completion: nil)
    }
}
