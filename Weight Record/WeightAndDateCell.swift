//
//  WeightAndDateCell.swift
//  BPW
//
//  Created by Robert Lummis on 7/11/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import Foundation
import UIKit

let borderViewTagValue = 4
let weightLTagValue = 3

class WeightAndDateCell: UITableViewCell {
   @IBOutlet weak var dayOfWeekL: UILabel!
   @IBOutlet weak var monthDayYearL: UILabel!
   @IBOutlet weak var hourMinuteL: UILabel!
   @IBOutlet weak var weightContainerV: UIView!
   @IBOutlet weak var commentDisplayL: UILabel!

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
      
      // weight is stored in kilograms; show it and expect new values in weightDisplayUnit
      dateFormatter.dateFormat = "MMM-dd-yyyy"
      monthDayYearL.text = dateFormatter.string(from: sample.date)
      monthDayYearL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: fontWeight))
      
      dateFormatter.dateFormat = "HH:mm"
      hourMinuteL.text = dateFormatter.string(from: sample.date)
      hourMinuteL.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: fontWeight))
      
      commentDisplayL.text = sample.note == "" ? "" : sample.note
      
      self.date = sample.date
   }
   
   // weight argument should be in the current weightDisplayUnit
   // fractionalChange is set to 0.0 in the last row of the table by VC
   internal func addWeightDisplayView(in containerV: UIView, weight: Double, fractionalChange: Double) {
      let model = Model.shared
      
      // width & height of containerV
      let w0 = containerV.bounds.size.width
      let h0 = containerV.bounds.size.height
      
      // width & height of the weightL
      let w = CGFloat(60)
      let h = CGFloat(25)
      
      // assume containerV is same aspect ratio as weightL or wider
      // thus its height is the limiting dimension for border thickness
      func borderThickness(fractionalChange: Double) -> CGFloat {
         let maxThickness = CGFloat(h0 - h) * 0.5    // border fills container vertically
         if fractionalChange == 0.0 { return 0.0 } 
         if abs(fractionalChange) <= 0.001 { return maxThickness * 0.05 }
         if abs(fractionalChange) <= 0.003 { return maxThickness * 0.1 }
         if abs(fractionalChange) <= 0.006 { return maxThickness * 0.15 }
         if abs(fractionalChange) <= 0.012 { return maxThickness * 0.25 }
         if abs(fractionalChange) <= 0.018 { return maxThickness * 0.32 }
         if abs(fractionalChange) <= 0.028 { return maxThickness * 0.4 }
         return maxThickness
      }
      
      let weightLFrame = CGRect(x: (w0 - w) * 0.5, y: (h0 - h) * 0.5, width: w, height: h)
      let weightL = UILabel(frame: weightLFrame)
      weightL.backgroundColor = UIColor.white
      weightL.textAlignment = .center
      weightL.font = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(18), weight: UIFont.Weight(rawValue: 0.0) )  // 0.0 normal, 1.0 heavy bold
      let weightDisplayPrecision = model.weightDisplayUnit == WeightUnit.stone ? 2 : 1
      weightL.text = weight.stringWithRounding(precision: weightDisplayPrecision)
      weightL.tag = weightLTagValue
      
      let borderWidth = borderThickness(fractionalChange: fractionalChange)
      let borderFrame = CGRect(x: (w0 - w) * 0.5 - borderWidth,
                               y: (h0 - h) * 0.5 - borderWidth,
                               width: w + 2.0 * borderWidth,
                               height: h + 2.0 * borderWidth )
      let borderView = UIView(frame: borderFrame)
      borderView.backgroundColor = fractionalChange <= 0.0 ? UIColor.green : UIColor.red
      borderView.tag = borderViewTagValue
      
      if let oldWeightL = containerV.viewWithTag(weightLTagValue) {
         oldWeightL.removeFromSuperview()
      }
      if let oldBorderView = containerV.viewWithTag(borderViewTagValue) {
         oldBorderView.removeFromSuperview()
      }
      
      containerV.addSubview(borderView)
      containerV.addSubview(weightL)

   }
}

