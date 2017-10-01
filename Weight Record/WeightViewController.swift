//
//  WeightViewController.swift
//  BPW
//
//  Created by Robert Lummis on 7/5/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import UIKit
import HealthKit

class WeightVC: UIViewController, WeightAndDateAndNoteDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
   
   @IBOutlet weak var messageL: UILabel!
   @IBOutlet weak var weightTF: UITextField!
   @IBOutlet weak var commentInputTF: UITextField!
   @IBOutlet weak var saveB: UIButton!
   @IBOutlet weak var deleteB: UIButton!
   @IBOutlet weak var doneB: UIButton!
   
   let hks = HKHealthStore()
   var helper: HealthKitHelper!
   var tableView: UITableView? = nil
   var dateFormatter = DateFormatter()
   var fromDate: Date!
   var toDate: Date!
   var isRemoveMessageInProgress: Bool = false
   var isWeightInValidRange: Bool = false
   var weightsAndDatesAndNotes: [ (kg: Double, date: Date, note: String) ]  = []
   let earliestDate: Date = .distantPast
   let latestDate: Date = .distantFuture
   
   var weightDisplayUnit: WeightUnit {
      get {
         return Model.shared.weightDisplayUnit
      }
   }
   
   var messageText: String {
      get {
         return messageL.text ?? "messageText initial value"
      }
      set {
         // don't call fadeThenRemoveMessage if it's already in progress
         if newValue != "" {
            fadeThenRemoveMessage()
         }
         messageL.text = newValue
      }
   }
   
   // helper notified us that a weight was stored; now we update the table to include the new weight
   var storeWeightSucceeded: Bool {
      get {
         return false
      }
      set {
         print("storeWeight succeeded: \(newValue)")
         if newValue == true {
            DispatchQueue.main.async {
               self.helper.getWeightsAndDates(fromDate: self.earliestDate, toDate: self.latestDate)
            }
         }
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm"
      helper = HealthKitHelper(delegate: self)
      weightTF.delegate = self
      weightTF.tintColor = UIColor.black
      commentInputTF.delegate = self
      commentInputTF.text = ""
      messageText = ""
      deleteB.isEnabled = false
      doneB.isHidden = true
      
      // move text right a little
      commentInputTF.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      saveB.isEnabled = false
      tableView?.setEditing(false, animated: true)
      doneB.isHidden = true // not needed?
      helper.getWeightsAndDates(fromDate: earliestDate, toDate: latestDate)
      weightTF.placeholder = weightDisplayUnit.pluralName() + "..."
      weightTF.text = ""
   }
   
   // enabled save button only when the weight is in the valid range, set in the extension
   @IBAction func weightTFTextChanged() {
      saveB.isEnabled = false
      if let w: String = weightTF.text {
         if let wt: Double = Double(w) {
            if wt >= minValue(weightDisplayUnit) && wt <= maxValue(weightDisplayUnit) {
               saveB.isEnabled = true
            }
         }
      }
   }
   
   func fadeThenRemoveMessage() {
      let delayUntilFadeOut: TimeInterval = 4.0
      let fadeDuration: TimeInterval = 1.0
      UIView.animate(withDuration: fadeDuration,
                     delay: delayUntilFadeOut,
                     options: [.curveEaseInOut],
                     animations: { self.messageL.alpha = 0.0 },
                     completion: { finished in
                        self.messageL.text = ""
                        self.messageL.alpha = 1.0
      })
   }
   
   func textFieldDidBeginEditing(_ textField: UITextField) {
      textField.isHighlighted = true
      textField.textColor = UIColor.black
   }
   
   func saveWeightsAndDatesAndNotesThenDisplay( wadan: [ (kg: Double, date: Date, note: String) ] ) {
      weightsAndDatesAndNotes = wadan
      updateCells()
      let nSamples = weightsAndDatesAndNotes.count
      messageText = "\(nSamples) weights"
      deleteB.isEnabled = nSamples > 0 ? true : false
   }
   
   @IBAction func saveAction(_ sender: Any) {
      weightTF.resignFirstResponder()
      commentInputTF.resignFirstResponder()
      
      if let wt = Double(weightTF.text!) {
         if wt >= minValue(weightDisplayUnit) && wt <= maxValue(weightDisplayUnit) {
            helper.storeWeight(kg: wt * weightDisplayUnit.unitToKgFactor(), unit: weightDisplayUnit, note: commentInputTF.text ?? "")
            weightTF.text = ""
            commentInputTF.text = ""
         } else {
            print("weight not in valid range")
         }
      } else {
         print("weight not valid")
      }
      
      saveB.isEnabled = false
   }
   
   @IBAction func deleteBAction(_ sender: Any) {
      tableView?.setEditing(true, animated: true)
      doneB.isHidden = false
   }
   
   @IBAction func doneBAction(_ sender: Any) {
      tableView?.setEditing(false, animated: true)
      doneB.isHidden = true
   }
   
   func removeRequestCompleted() {
      print("remove request completed")
      updateUI()
   }
   
   func updateUI() {
      weightsAndDatesAndNotes = []
      helper.getWeightsAndDates(fromDate: earliestDate, toDate: latestDate)   // triggers updateCells()
   }
   
   func updateCells() {
      if tableView != nil && !weightsAndDatesAndNotes.isEmpty {
         tableView!.reloadData()
      } else {
         messageText = "Can't access weight in the Apple Health app. Verify that it is set to permit 'write' and 'read'."
         print("updateCells failed; tableView is nil or weightsAndDates is empty")
      }
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      super.prepare(for: segue, sender: sender)

      let svc = segue.destination as! SettingsVC
      svc.wvc = self
   }
   
   func numberOfSections(in tableView: UITableView) -> Int {
      self.tableView = tableView
      return 1
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      assert(section == 0, "fatal error: tableView asks for number of rows in section \(section)")
      return weightsAndDatesAndNotes.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "weightAndDateCell", for: indexPath) as! WeightAndDateCell
      cell.updateFields(withSample: weightsAndDatesAndNotes[indexPath.row], displayUnit: weightDisplayUnit)
      
      // following is thanks to kosuke-ogawa https://stackoverflow.com/questions/45537762/swift3-cells-with-image-is-not-displayed
      UIGraphicsBeginImageContext(cell.frame.size)
      UIImage(named: "lightBlue.png")?.draw(in: cell.bounds)
      if let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
         cell.backgroundColor = UIColor(patternImage: image)
      }
      UIGraphicsEndImageContext()
      return cell
   }
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      let cell = tableView.cellForRow(at: indexPath) as! WeightAndDateCell
      let helper = HealthKitHelper(delegate: self)
      helper.removeSampleFromHKStore(sampleDate: cell.date)
   }
   
   // reset weightTF but keep commentTF.text
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      print("touchesBegan")
      super.touchesBegan(touches, with: event)
      weightTF.text = ""
      view.endEditing(true)
   }
}

extension WeightVC {
   
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
   
}
