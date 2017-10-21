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
      let fontWeight = dayName == "Mon" ? CGFloat(0.0) : CGFloat (0.0)
      // stop using alternate fontWeight (Mon was 0.7). It might be responsible for the frame being misplaced
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
   fileprivate func borderWidth(fractionalChange: Double) -> CGFloat {
      if abs(fractionalChange) <= 0.001 { return CGFloat(0.0) }
      if abs(fractionalChange) <= 0.003 { return CGFloat(1) }
      if abs(fractionalChange) <= 0.006 { return CGFloat(2) }
      if abs(fractionalChange) <= 0.009 { return CGFloat(3) }
      if abs(fractionalChange) <= 0.0125 { return CGFloat(4) }
      if abs(fractionalChange) <= 0.017 { return CGFloat(5) }
      if abs(fractionalChange) <= 0.023 { return CGFloat(6) }
      else { return CGFloat(8) }
   }
   
   fileprivate func borderColor(fractionalChange: Double) -> UIColor {
      if (fractionalChange <= 0.0) { return UIColor.green }
      else { return UIColor.red }
   }
   
   internal func addBorder(cell: WeightAndDateCell, row: Int, fractionalChange: Double) {
      let weightLabel = cell.weightL!
      let x0 = weightLabel.frame.origin.x
      let y0 = weightLabel.frame.origin.y
      let width0 = weightLabel.bounds.size.width
      let height0 = weightLabel.bounds.size.height
      let thickness = CGFloat( borderWidth(fractionalChange: fractionalChange) )
      let borderFrame = CGRect(x: x0 - thickness, y: y0 - thickness, width: width0 + thickness * 2.0, height: height0 + thickness * 2.0)
      let borderView = UIView(frame: borderFrame)
      print("addingBorder for row \(row); weight: \(cell.weightL.text!); weightLabel.frame x0: \(x0), y0: \(y0), width0: \(width0), height0: \(height0)")
      print("border thickness: \(thickness)")
      debugPrint("weightLabel: \(weightLabel)")
      debugPrint("borderView: \(borderView)")
      borderView.backgroundColor = borderColor(fractionalChange: fractionalChange)
      borderView.tag = borderViewTagValue
      if let oldBorder = cell.viewWithTag(borderViewTagValue) {
         oldBorder.removeFromSuperview()
      }
      weightLabel.superview!.insertSubview(borderView, belowSubview: weightLabel)
   }
}

