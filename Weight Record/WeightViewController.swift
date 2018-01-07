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

class WeightVC: UIViewController, WeightAndDateAndNoteDelegate, WeightAndDateCellVC, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
   
   @IBOutlet weak var messageL: UILabel!
   @IBOutlet weak var weightTF: UITextField!
   @IBOutlet weak var commentInputTF: UITextField!
   @IBOutlet weak var buttonA: UIButton!
   @IBOutlet weak var buttonB: UIButton!
   @IBOutlet weak var deleteB: UIButton!
   @IBOutlet weak var buttonC: UIButton!
   
   var helper: HealthKitHelper!
   var tableView: UITableView? = nil
   var dateFormatter = DateFormatter()
//   var isWeightInValidRange: Bool = false // not used?
   let earliestDate: Date = .distantPast
   let latestDate: Date = .distantFuture
   var buttonCDefaultTitle = ""  // set in viewDidAppear
   var model = Model.shared
   var oldMonthDayYearL: UILabel? = nil
   var oldTextFieldText = ""
   
   enum State {
      case waiting, entering, inRange, deleting
   }
   
   var state: State = .waiting {
      didSet (oldState) {
 //    buttonA and weightTF occupy the same place and have opposite isHidden properties
         
         deleteB.isHidden = false
         deleteB.setTitle("Delete", for: .normal)
         buttonA.isHidden = false
         buttonB.isHidden = true
         buttonB.setTitle("Cancel",for: .normal)
         buttonC.isHidden = false
         weightTF.isHidden = true
         commentInputTF.isHidden = false
         switch state {
         case .waiting:
            break
         case .entering:
            buttonA.isHidden = true
            weightTF.isHidden = false
            if weightTF.isFirstResponder == false {
               weightTF.becomeFirstResponder()
            }
            buttonB.isHidden = false
            buttonB.setTitle("Cancel", for: .normal)
            buttonC.isHidden = true
            deleteB.isHidden = true
         case .inRange:
            buttonA.isHidden = true
            weightTF.isHidden = false
            buttonB.isHidden = false
            buttonB.setTitle("Save", for: .normal)
            buttonC.isHidden = true
         case .deleting:
            buttonA.isHidden = true
            buttonC.isHidden = true
            weightTF.isHidden = true
            deleteB.setTitle("Done deleting", for: .normal)
            commentInputTF.isHidden = true
         }
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
   
   // helper added a new weight to HKStore; now update the table to include the new weight
   var storeWeightSucceeded: Bool {
      get {
         return false
      }
      set {
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
      model.vc = self
      
      // move text right a little
//      commentInputTF.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
      
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      state = .waiting
      tableView?.setEditing(false, animated: true)
      helper.getWeightsAndDates(fromDate: earliestDate, toDate: latestDate)
      weightTF.placeholder = model.weightDisplayUnit.pluralName() + "..."
      weightTF.text = ""
      buttonCDefaultTitle = buttonC.titleLabel!.text!
      
      let sb = UIStoryboard(name: "Main", bundle: nil)
      debugPrint("Main sb: \(sb)")
   }
   
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      // we have only one textField, so textField is the same as weightTF
      let textAsString = weightTF.text!
      if string.count == 0 && textAsString.last == "." { // delete button and last char is decimal dot
         weightTF.text = String(textAsString.dropLast(2))   // must convert subString to String before assigning it to a String
         weightTFTextChanged()
         return false
      }
      return true
   }
   
   // enabled save button only when the weight is in the valid range, set in the extension
   // inputString must be all numbers because numeric keyboard is specified
   // backspace key apparently takes effect before this func is called so we never see bs
   @IBAction func weightTFTextChanged() {
      if let inputString = weightTF.text {
         if inputString.count == 3 {
            weightTF.text = inputString + "."
         }
         let value = Double(weightTF.text!)!
         state = model.isInRange(value) ? .inRange : .entering
      }
   }
   
   func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      oldTextFieldText = textField.text!
      print(oldTextFieldText)
      return true
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
      state = .entering
   }
   
   @IBAction func buttonBAction(_ sender: UIButton) {
      if sender.titleLabel!.text == "Cancel" {
         weightTF.resignFirstResponder()
         state = .waiting
      } else if sender.titleLabel!.text == "Save" {
         state = .waiting
         save()
      } else {
         print("error in buttonBAction")
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
         state = .waiting
      }
   }
   
   @IBAction func buttonCAction(_ sender: UIButton) {
      if sender.titleLabel!.text == "Done" {
         tableView?.setEditing(false, animated: true)
         buttonC.titleLabel!.text = buttonCDefaultTitle
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
   
   func saveMonthDayYearL(_ currentLabel: UILabel) {
      if oldMonthDayYearL != nil {
         oldMonthDayYearL!.isHidden = oldMonthDayYearL!.text == currentLabel.text ? true : false
      }
      oldMonthDayYearL = currentLabel
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
      let section = indexPath.section
      let row = indexPath.row
      let thisSample = weightsAndDatesAndNotes[indexPath.row]
      var previousSample: (kg: Double, date: Date, note: String)?
      if row != 0 {
         let previousIndexPath = IndexPath(row: row - 1, section: section)
         previousSample = weightsAndDatesAndNotes[previousIndexPath.row]
      } else {
         previousSample = nil
      }
      cell.updateFields(withSample: thisSample, previousSample: previousSample, displayUnit: model.weightDisplayUnit)
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
