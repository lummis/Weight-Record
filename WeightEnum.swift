//
//  WeightEnum.swift
//  Weight Record
//
//  Created by Robert Lummis on 8/20/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import Foundation

internal enum WeightUnit: Int {
   
   // don't start with rawValue == 0 so 0 can be used to signal first execution
   case kilogram = 10, pound, stone
   
   internal func pluralName() -> String {
      switch self {
      case .kilogram:
         return "kilograms"
      case .pound:
         return "pounds"
      case .stone:
         return "stone"
      }
   }
   
   internal func abbreviation() -> String {
      switch self {
      case .kilogram:
         return "Kg."
      case .pound:
         return "Lb."
      case .stone:
         return "St."
      }
   }
   
   internal func unitToKgFactor() -> Double {
      switch self {
      case .kilogram:
         return 1.0
      case .pound:
         return 0.453592
      case .stone:
         return 6.35029
      }
   }
}

