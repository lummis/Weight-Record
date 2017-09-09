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
    
    @IBOutlet weak var segmentedC: UISegmentedControl!
    var wvc: WeightVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        segmentedC.selectedSegmentIndex = Model.shared.weightDisplayUnit.rawValue - 10
        let wu: WeightUnit = WeightUnit.stone
        print(wu)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
    }
    
    @IBAction func doneVAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentedCAction(_ sender: UISegmentedControl) {
        Model.shared.weightDisplayUnit = WeightUnit(rawValue: sender.selectedSegmentIndex + 10)!
//        weightTF.text = ""
//        updateCells()
//        emphasizeTextField(nil) // deemphasize all UITextFields
    }
    

}
