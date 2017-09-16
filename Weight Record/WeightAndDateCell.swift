//
//  WeightAndDateCell.swift
//  BPW
//
//  Created by Robert Lummis on 7/11/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import Foundation
import UIKit

class WeightAndDateCell: UITableViewCell {
    @IBOutlet weak var dayOfWeekL: UILabel!
    @IBOutlet weak var monthDayYearL: UILabel!
    @IBOutlet weak var hourMinuteL: UILabel!
    @IBOutlet weak var weightL: UILabel!
    
    func updateFields(withSample sample: (kg: Double, date: Date), displayUnit: WeightUnit) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        
        dateFormatter.dateFormat = "ccc"
        let dayName = dateFormatter.string(from: sample.date)
        let fontSize = CGFloat(18.0)
        
            // table row bolder every Monday to emphasize weeks
            // font weight 0.0 is 'regular'; range is -1.0 to 1.0        
        let fontWeight = dayName == "Mon" ? CGFloat(0.7) : CGFloat (0.0)
        dayOfWeekL.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        dayOfWeekL.text = dayName
        
        // weight is stored in kilograms; show it and expect new values in display units
        let weightInDisplayUnit = sample.kg / displayUnit.unitToKgFactor()
        weightL.text = displayUnit == WeightUnit.stone ? weightInDisplayUnit.stringWithRounding(precision: 2)
            : weightInDisplayUnit.stringWithRounding(precision: 1)
        weightL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        
        dateFormatter.dateFormat = "MMM-dd-yyyy"
        monthDayYearL.text = dateFormatter.string(from: sample.date)
        monthDayYearL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        
        dateFormatter.dateFormat = "HH:mm"
        hourMinuteL.text = dateFormatter.string(from: sample.date)
        hourMinuteL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
    }
}

extension Double {
    
    // precision is the number of digits dessired after the decimal place
    // 0 means no fractional part and also no decimal point
    // if the Double has no fractional part 'precision' zeros will be added
    // negative precision seems to act the same as 0. don't use negative without further testing
    func stringWithRounding(precision: Int) -> String {
        assert(precision >= 0, "negative precision is not supported in 'func stringWithRounding'")
        let p = String(format: "%1d", precision)
        let theFormat = "%." + p + "f"
        return String(format: theFormat, self)
    }
    
}
