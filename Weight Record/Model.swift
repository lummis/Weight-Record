//
//  Model.swift
//  Weight Record
//
//  Created by Robert Lummis on 8/30/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//
// userDefaults stores the weightDisplayUnit's rawValue + 10
// so we can distinguish a rawValue = 0 from a 0 indicating no such key was set

import Foundation
import UIKit
import HealthKit

class Model {
   
/*
    class Singleton {
       static let sharedInstance = Singleton()
    }
    
    if setup is needed:
    class Singleton {
    static let sharedInstance: Singleton = {
       let instance = Singleton()
       // setup code
       return instance
       }()
    }
    
    Excerpt From: Apple Inc. “Using Swift with Cocoa and Objective-C (Swift 4 beta).” iBooks.
 */
   
   static let shared = Model()   // singleton
   
   var vc: WeightVC!
   private let userDefaults = UserDefaults.standard
   private let weightDisplayUnitDefault: WeightUnit = .kilogram
   private var weight10DayTrailingAvg: [Double] = []
   
   var weightDisplayUnit: WeightUnit {
      willSet (newUnit) {
         print("weightDisplayUnit being set to unit: \(newUnit)")
         if newUnit != weightDisplayUnit {
            print("userDefaults changed to newUnit: \(newUnit)")
            userDefaults.set(newUnit.rawValue, forKey: "weightDisplayUnitRawValue")
            userDefaults.synchronize()
         }
      }
      didSet {
         // debug
         print("in didSet current weightDisplayUnit: ", weightDisplayUnit)
      }
   }
   
   internal init() {
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
   // return nil if the key is not set
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

   // min and max valid weight
   func minValue(_ unit: WeightUnit) -> Double {
      switch(unit) {
      case .kilogram: return 18.0     // 18.143695
      case .pound:    return 40.0
      case .stone:   return 2.85     // 2.857143
      }
   }

   func maxValue(_ unit: WeightUnit) -> Double {
      switch(unit) {
      case .kilogram: return 180.0    // 180.873356
      case .pound:    return 399.0
      case .stone:    return 28.5     // 28.5000
      }
   }

   func isInRange(_ wt: Double) -> Bool {
      if wt >= minValue(weightDisplayUnit) && wt <= maxValue(weightDisplayUnit) {
         return true
      }
      return false
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
