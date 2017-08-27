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
    
    // weight argument should in kg because it comes from the healthDB
    // unit arg not needed?
    func updateFields(withSample sample: (weight: Double, date: Date), unit: WeightUnit) {
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
        
        weightL.text = String(format: "%5.1f", sample.weight)
        weightL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        
        dateFormatter.dateFormat = "MMM-dd-yyyy"
        monthDayYearL.text = dateFormatter.string(from: sample.date)
        monthDayYearL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        
        dateFormatter.dateFormat = "HH:mm"
        hourMinuteL.text = dateFormatter.string(from: sample.date)
        hourMinuteL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        
    }
    
}
