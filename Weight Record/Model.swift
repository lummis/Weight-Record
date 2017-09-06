//
//  Model.swift
//  Weight Record
//
//  Created by Robert Lummis on 8/30/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//
// userDefaults stores the weightDisplayUnit's rawValue + 100
// so we can distinguish a rawValue = 0 from a 0 indicating no such key was set

import Foundation
import HealthKit

let userDefaults = UserDefaults.standard

class Model {
    
    static var shared = Model()
    let weightDisplayUnitDefault: WeightUnit = .kilogram
    var weightDisplayUnit: WeightUnit {
        willSet (preferredUnit) {
            if preferredUnit != weightDisplayUnit {
                userDefaults.set(preferredUnit.rawValue, forKey: "preferredWeightDisplayUnitRawValue")
            }
        }
    }

    private init() {
        let rv = userDefaults.integer(forKey: "preferredWeightDisplayUnitRawValue")
        if rv == 0 {    // 0 means first time running this app
            weightDisplayUnit = weightDisplayUnitDefault
        } else {
            if let wu = WeightUnit(rawValue: rv) {
                weightDisplayUnit = wu
            } else {
                print("wu invalid")
                weightDisplayUnit = weightDisplayUnitDefault
            }
        }
    }
    
    // return nil if the key was never set
    func weightDisplayUnitRawValue() -> WeightUnit.RawValue? {
        let rv = userDefaults.integer(forKey: "preferredWeightDisplayUnitRawValue")
            if rv == 0 {
                return nil
            } else {
                return rv
            }
    }
    
}
