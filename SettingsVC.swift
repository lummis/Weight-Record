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
      
      segmentedC.selectedSegmentIndex = Model.shared.weightDisplayUnit.rawValue - 10
   }
   
   @IBAction func doneVAction(_ sender: Any) {
      dismiss(animated: true, completion: nil)
   }
   
   @IBAction func segmentedCAction(_ sender: UISegmentedControl) {
      Model.shared.weightDisplayUnit = WeightUnit(rawValue: sender.selectedSegmentIndex + 10)!

      print()
      print("model.weightDisplayUnit: \(Model.shared.weightDisplayUnit)")
      print("userDefaults weightDisplayUnitRawValue: \(UserDefaults.standard.integer(forKey: "weightDisplayUnitRawValue"))")
      print("model.minValue: \(Model.shared.minValue(Model.shared.weightDisplayUnit))")
      debugPrint("model address: \(Model.shared)")
   }
   
}
