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
   @IBOutlet weak var commentDisplayL: UILabel!
   
   // date property is used as unique field for identifying a value for deletion from HKStore
   var date: Date!
   
   func updateFields(withSample sample: (kg: Double, date: Date, note: String), displayUnit: WeightUnit) {
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = .current
      
      dateFormatter.dateFormat = "ccc"
      let dayName = dateFormatter.string(from: sample.date)
      let fontSize = CGFloat(18.0)
      
      // table row bolder every Monday to emphasize weeks
      // font weight 0.0 is 'regular'; range is -1.0 to 1.0
      let fontWeight = dayName == "Mon" ? CGFloat(0.7) : CGFloat (0.0)
      dayOfWeekL.font = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: fontWeight))
      dayOfWeekL.text = dayName
      
      // weight is stored in kilograms; show it and expect new values in display units
      let weightInDisplayUnit = sample.kg / displayUnit.unitToKgFactor()
      weightL.text = displayUnit == WeightUnit.stone ? weightInDisplayUnit.stringWithRounding(precision: 2)
         : weightInDisplayUnit.stringWithRounding(precision: 1)
      weightL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: fontWeight))
      
      dateFormatter.dateFormat = "MMM-dd-yyyy"
      monthDayYearL.text = dateFormatter.string(from: sample.date)
      monthDayYearL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: fontWeight))
      
      dateFormatter.dateFormat = "HH:mm"
      hourMinuteL.text = dateFormatter.string(from: sample.date)
      hourMinuteL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: fontWeight))
      
      commentDisplayL.text = sample.note == "" ? "" : sample.note
      
      self.date = sample.date
   }
}

