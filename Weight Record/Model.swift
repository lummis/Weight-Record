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

class Model {
    
    static var shared = Model()
    
    private let userDefaults = UserDefaults.standard
    private let weightDisplayUnitDefault: WeightUnit = .kilogram
    
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
            } else {    // if a wacky value is stored in userDefaults
                weightDisplayUnit = weightDisplayUnitDefault
            }
        }
    }
    
    // return the value stored in userDefaults
    // return nil if the key was never set
    internal func weightDisplayUnitRawValue() -> WeightUnit.RawValue? {
        let rawValue = userDefaults.integer(forKey: "weightDisplayUnitRawValue")
        return rawValue == 0 ? nil : rawValue
    }
    
}
