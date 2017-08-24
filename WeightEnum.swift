//
//  WeightEnum.swift
//  Weight Record
//
//  Created by Robert Lummis on 8/20/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import Foundation

enum WeightUnit: Int {
    case kilogram = 0, pound, stone
    
    func abbreviation() -> String {
        switch self {
        case .kilogram:
            return "kg"
        case .pound:
            return "lb"
        case .stone:
            return "st"
        }
    }
    
    func unitToKgFactor() -> Double {
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
