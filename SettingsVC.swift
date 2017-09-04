//
//  SettingsVC.swift
//  Weight Record
//
//  Created by Robert Lummis on 9/3/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
    }
    
    @IBAction func doneVAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }

}
