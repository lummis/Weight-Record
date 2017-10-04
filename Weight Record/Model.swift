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
import UIKit
import HealthKit

// global data array
var weightsAndDatesAndNotes: [ (kg: Double, date: Date, note: String) ]  = []

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
   
   internal func color(forFractionalChange delta: Double) -> UIColor {
      if abs(delta) < 0.002 {
         return UIColor.white
      }
      let alpha = CGFloat(abs(75.0 * delta))
      return delta < 0 ? UIColor.green.withAlphaComponent(alpha) : UIColor.red.withAlphaComponent(alpha)
   }
}

extension Double {
    // for print formatting: stringWithRounding(precision: Int) -> String
    // precision is the number of digits desired after the decimal place
    // 0 means no fractional part and also no decimal point
    // if the Double has no fractional part 'precision' zeros will be added
    // negative precision seems to act the same as 0. don't use negative without further testing
    func stringWithRounding(precision: Int) -> String {
        assert(precision >= 0, "negative precision is not supported in 'func stringWithRounding'")
        let precision = String(format: "%1d", precision)
        let theFormat = "%." + precision + "f"
        return String(format: theFormat, self)
    }
    
}
