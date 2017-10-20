//
//  WeightAndDateCell.swift
//  BPW
//
//  Created by Robert Lummis on 7/11/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import Foundation
import UIKit

let borderViewTagValue = 77

class WeightAndDateCell: UITableViewCell {
   @IBOutlet weak var dayOfWeekL: UILabel!
   @IBOutlet weak var monthDayYearL: UILabel!
   @IBOutlet weak var hourMinuteL: UILabel!
   @IBOutlet weak var weightL: UILabel!
//   @IBOutlet weak var commentDisplayL: UILabel!
   
   // date property is used as unique field for identifying a value for deletion from HKStore
   internal var date: Date!
   
   internal func updateFields(withSample sample: (kg: Double, date: Date, note: String), displayUnit: WeightUnit) {
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
      
//      commentDisplayL.text = sample.note == "" ? "" : sample.note
      
      self.date = sample.date
   }
   
   // values planned in file 'BorderThickness vs Fractional Change'
   fileprivate func borderWidth(fractionalChange: Double) -> Double {
      if abs(fractionalChange) <= 0.001 { return 0.0 }
      if abs(fractionalChange) <= 0.003 { return 1.0 }
      if abs(fractionalChange) <= 0.006 { return 2.0 }
      if abs(fractionalChange) <= 0.009 { return 3.0 }
      if abs(fractionalChange) <= 0.0125 { return 4.0 }
      if abs(fractionalChange) <= 0.017 { return 5.0 }
      if abs(fractionalChange) <= 0.023 { return 6.0 }
      else { return 8.0 }
   }
   
   fileprivate func borderColor(fractionalChange: Double) -> UIColor {
      if (fractionalChange <= 0.0) { return UIColor.green }
      else { return UIColor.red }
   }
   
   var callNumber = 0
   internal func addBorder(cell: WeightAndDateCell, fractionalChange: Double) {
      callNumber += 1
      print()
      print("addingBorder \(callNumber)")
      let weightLabel = cell.weightL!
      let x0 = weightLabel.frame.origin.x
      let y0 = weightLabel.frame.origin.y
      let width0 = weightLabel.bounds.size.width
      let height0 = weightLabel.bounds.size.height
      let thickness = CGFloat( borderWidth(fractionalChange: fractionalChange) )
      let borderFrame = CGRect(x: x0 - thickness, y: y0 - thickness, width: width0 + thickness * 2.0, height: height0 + thickness * 2.0)
      let borderView = UIView(frame: borderFrame)
      print("x0: \(x0), y0: \(y0), width0: \(width0), height0: \(height0)")
      print("thickness: \(thickness)")
      debugPrint("weightLabel: \(weightLabel)")
      debugPrint("borderView: \(borderView)")
      borderView.backgroundColor = borderColor(fractionalChange: fractionalChange)
      borderView.tag = borderViewTagValue
      let oldBorder = cell.viewWithTag(borderViewTagValue)
      if oldBorder != nil { oldBorder!.removeFromSuperview() }
      weightLabel.superview!.insertSubview(borderView, belowSubview: weightLabel)
//      contentView.insertSubview(borderView, belowSubview: weightLabel)
//      cell.sendSubview(toBack: borderView)
      
      callNumber += 1
      if callNumber == 3 {
         debugPrint("subviews ", cell.subviews)
      }
   }
}

