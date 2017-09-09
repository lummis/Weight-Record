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
        willSet (newUnit) {
            if newUnit != weightDisplayUnit {
                userDefaults.set(newUnit.rawValue, forKey: "weightDisplayUnitRawValue")
            }
        }
    }

    private init() {
        let rawValue = userDefaults.integer(forKey: "weightDisplayUnitRawValue")
        if rawValue == 0 {    // 0 means first time running this app
            weightDisplayUnit = weightDisplayUnitDefault
        } else {
            if let unit = WeightUnit(rawValue: rawValue) {
                weightDisplayUnit = unit
            } else {
                weightDisplayUnit = weightDisplayUnitDefault
            }
        }
    }
    
    // return nil if the key was never set
    func weightDisplayUnitRawValue() -> WeightUnit.RawValue? {
        let rawValue = userDefaults.integer(forKey: "weightDisplayUnitRawValue")
            if rawValue == 0 {
                return nil
            } else {
                return rawValue
            }
    }
    
}
