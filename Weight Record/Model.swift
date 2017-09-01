//
//  Model.swift
//  Weight Record
//
//  Created by Robert Lummis on 8/30/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import Foundation
import HealthKit

let userDefaults = UserDefaults.standard

class Model {
    
    // userDefaults stores the weightDisplayUnit's rawValue + 100
    // so we can distinguish a rawValue = 0 from a 0 indicating no such key was set
    func storePreferred(weightDisplayUnitRawValue: WeightUnit.RawValue) {
        userDefaults.set(weightDisplayUnitRawValue + 100, forKey: "preferredWeightDisplayUnitRawValue")
    }
    
    // return nil if the key was never set
    func weightDisplayUnitRawValue() -> WeightUnit.RawValue? {
        let rv = userDefaults.integer(forKey: "preferredWeightDisplayUnitRawValue")
            if rv == 0 {
                return nil
            } else {
                return rv - 100
            }
    }
    
}
