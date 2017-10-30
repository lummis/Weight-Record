//
//  WeightViewController.swift
//  BPW
//
//  Created by Robert Lummis on 7/5/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import UIKit
import HealthKit

// global data
var weightsAndDatesAndNotes: [ (kg: Double, date: Date, note: String) ]  = []

class WeightVC: UIViewController, WeightAndDateAndNoteDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
   
   @IBOutlet weak var messageL: UILabel!
   @IBOutlet weak var weightTF: UITextField!
   @IBOutlet weak var commentInputTF: UITextField!
   @IBOutlet weak var buttonA: UIButton!
   @IBOutlet weak var deleteB: UIButton!
   @IBOutlet weak var buttonB: UIButton!
   
   var helper: HealthKitHelper!
   var tableView: UITableView? = nil
   var dateFormatter = DateFormatter()
   var isWeightInValidRange: Bool = false
   let earliestDate: Date = .distantPast
   let latestDate: Date = .distantFuture
   var buttonBDefaultTitle = ""  // set in viewDidAppear
   enum State {
      case blank, entering, inRange, outOfRange, deleting
   }
   
   var state: State = .blank {
      didSet (oldState) {
         deleteB.setTitle("Delete", for: .normal)
         buttonA.isHidden = false
         buttonB.isHidden = false
         deleteB.isHidden = false
         weightTF.isHidden = false
         commentInputTF.isHidden = false
         switch state {
         case .inRange:
            buttonA.setTitle("Save", for: .normal)
            weightTF.isHidden = false
            deleteB.isHidden = true
            buttonB.isHidden = true
         case .outOfRange:
            buttonA.setTitle("Cancel", for: .normal)
            deleteB.isHidden = true
            buttonB.isHidden = true
         case .blank:
            buttonA.setTitle("Enter Weight", for: .normal)
            weightTF.isHidden = true
         case .deleting:
            buttonA.isHidden = true
            buttonB.isHidden = true
            weightTF.isHidden = true
            deleteB.setTitle("Done deleting", for: .normal)
            commentInputTF.isHidden = true

         default:
            buttonA.setTitle("Cancel", for: .normal)
         }
      }
   }
   
   var model = Model.shared
   
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
   
   // helper added a new weight to HKStore; now update the table to include the new weight
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
   
   // helper removed a weight from HKStore; now update the table to delete the weight
   func removeRequestCompleted() {
      updateUI()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm"
      helper = HealthKitHelper(delegate: self)
      weightTF.delegate = self
      weightTF.tintColor = UIColor.black
      weightTF.isHidden = true
      commentInputTF.delegate = self
      commentInputTF.text = ""
      messageText = ""
//      model.vc = self
      
      // move text right a little
//      commentInputTF.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
      
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      state = .blank
      tableView?.setEditing(false, animated: true)
      helper.getWeightsAndDates(fromDate: earliestDate, toDate: latestDate)
      weightTF.placeholder = model.weightDisplayUnit.pluralName() + "..."
      weightTF.text = ""
      buttonBDefaultTitle = buttonB.titleLabel!.text!
      
      let sb = UIStoryboard(name: "Main", bundle: nil)
      debugPrint("Main sb: \(sb)")
   }
   
   // enabled save button only when the weight is in the valid range, set in the extension
   @IBAction func weightTFTextChanged() {
      if let w: String = weightTF.text {
         if let wt: Double = Double(w) {
            if model.isInRange(wt) { state = .inRange } else { state = .outOfRange }
         }
      }
   }
   
   func textFieldDidBeginEditing(_ textField: UITextField) {
      textField.isHighlighted = true
      textField.textColor = UIColor.black
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
   
   func saveWeightsAndDatesAndNotesThenDisplay( wadan: [ (kg: Double, date: Date, note: String) ] ) {
      weightsAndDatesAndNotes = wadan
      updateCells()
      let nSamples = weightsAndDatesAndNotes.count
      messageText = "\(nSamples) weights"
   }
   
   @IBAction func buttonAAction(_ sender: UIButton) {
      switch sender.titleLabel!.text! {
      case "Enter Weight":
         state = .outOfRange
      case "Save":
         state = .blank
         save()
      case "Cancel":
         state = .blank
      default:
         state = .blank
      }
   }
   
   func save() {
      weightTF.resignFirstResponder()
      commentInputTF.resignFirstResponder()
      
      if let wt = Double(weightTF.text!) {
         if model.isInRange(wt) {
            helper.storeWeight(kg: wt * model.weightDisplayUnit.unitToKgFactor(), unit: model.weightDisplayUnit, note: commentInputTF.text ?? "")
            weightTF.text = ""
            commentInputTF.text = ""
         } else {
            print("weight not in valid range")
         }
      } else {
         print("weight not valid")
      }
      
   }
   
   @IBAction func deleteBAction(_ sender: UIButton) {
      if sender.titleLabel!.text == "Delete" {
         tableView?.setEditing(true, animated: true)
         state = .deleting
      } else if sender.titleLabel!.text == "Done deleting" {
         tableView?.setEditing(false, animated: true)
         weightTF.text = ""
         state = .blank
      }
   }
   
   @IBAction func buttonBAction(_ sender: UIButton) {
      if sender.titleLabel!.text == "Done" {
         tableView?.setEditing(false, animated: true)
         buttonB.titleLabel!.text = buttonBDefaultTitle
      } else if sender.titleLabel!.text == "Setup" {
         performSegue(withIdentifier: "WeightVC-SettingsVC", sender: self)
         }
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
      cell.updateFields(withSample: weightsAndDatesAndNotes[indexPath.row], displayUnit: model.weightDisplayUnit)
      return cell
   }
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      let cell = tableView.cellForRow(at: indexPath) as! WeightAndDateCell
      let helper = HealthKitHelper(delegate: self)
      helper.removeSampleFromHKStore(dateToBeDeleted: cell.date)
   }
   
   func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

      let thisCell: WeightAndDateCell = cell as! WeightAndDateCell
      let thisWeightInKg = weightsAndDatesAndNotes[indexPath.row].kg
      
      var fractionalChange = 0.0
      if indexPath.row != weightsAndDatesAndNotes.count - 1 { // not the last row of table
         let previousWeightInKg = weightsAndDatesAndNotes[indexPath.row + 1].kg
         fractionalChange = (thisWeightInKg - previousWeightInKg) / previousWeightInKg
      }
      thisCell.addWeightDisplayView(in: thisCell.weightContainerV,
                                    weight: thisWeightInKg / model.weightDisplayUnit.unitToKgFactor(),
                                    fractionalChange: fractionalChange )
   }
   
   // for debugging
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)

      // if user starts entering text then decides against it
      weightTF.resignFirstResponder()
      commentInputTF.resignFirstResponder()
      
      print()
      print("model.weightDisplayUnit: \(model.weightDisplayUnit)")
      print("userDefaults weightDisplayUnitRawValue: \(UserDefaults.standard.integer(forKey: "weightDisplayUnitRawValue"))")
      print("model.minValue: \(model.minValue(model.weightDisplayUnit))")
   }
}
