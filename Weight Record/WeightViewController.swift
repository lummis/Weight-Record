//
//  WeightViewController.swift
//  BPW
//
//  Created by Robert Lummis on 7/5/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import UIKit
import HealthKit

class WeightVC: UIViewController, WeightAndDateProtocol, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var noteTF: UITextField!
    @IBOutlet weak var segmentedC: UISegmentedControl!
    
    let hks = HKHealthStore()
    var helper: HealthKitHelper!
    var tableView: UITableView? = nil
    var dateFormatter = DateFormatter()
    var fromDate: Date!
    var toDate: Date!
    var isRemoveMessageInProgress: Bool = false
    var weightsAndDates: [ (kg: Double, date: Date) ]  = []
    //FIXME: persist value
    // weight is always saved and retrieved in kg but is displayed in kg, lb, or st
    var weightDisplayUnit: WeightUnit = .kilogram
    let delayUntilFadeOut: TimeInterval = 4.0
    let fadeDuration: TimeInterval = 1.0
    
    var messageText: String {
        get {
            return messageL.text ?? "messageText initial value"
        }
        set {
            // don't call fadeThenRemoveMessage if it's already in progress
            if newValue != "" && !isRemoveMessageInProgress {
                fadeThenRemoveMessage()
            }
            messageL.text = newValue
        }
    }
    
    var saveWeightSucceeded: Bool {
        get {
            return false
        }
        set {
            print("saveWeight succeeded: \(newValue)")
            if newValue == true {
                DispatchQueue.main.async {
                    self.didSaveWeight()
                }
            }
        }
    }
    
    func fadeThenRemoveMessage() {
        print("begin fadeThenRemoveMessage")
        
        UIView.animate(withDuration: fadeDuration, delay: delayUntilFadeOut, options: [.curveEaseInOut],
                       animations: { self.messageL.alpha = 0.0 },
                       completion: { finished in
                        self.messageL.text = ""
                        self.messageL.alpha = 1.0
                        self.isRemoveMessageInProgress = false
                        print("end fadeThenRemoveMessage")
        } )
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        textField.layer.borderWidth = 2.0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("tf before: \(textField.text ?? "blank")")
        let rangeString = NSStringFromRange(range)
        print("range: \(range)      rangeString: \(rangeString)     replacementString: \(string)")
        if string == "" && textField.text?.characters.count == 1 {
            weightText = ""
        }
        return true
    }
    
    // this is the text in the weightTF outlet
    // it probably doesn't have to be managed this way but it's convenient
    var weightText: String {
        get {
            return weightTF.text ?? ""
        }
        
        set {
            weightTF.text = newValue
        }
    }
    
    // I guess the following is not needed; originally it did more
    var noteText: String {
        get{
            return noteTF.text!
        }
        
        set{
            noteTF.text = newValue  // if empty show placeholder text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //FIXME: persist segment selection
        let segmentIndex = 1  // start with Lb selected
        segmentedC.selectedSegmentIndex = segmentIndex
        weightDisplayUnit = WeightUnit(rawValue: segmentIndex)!
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm"
        helper = HealthKitHelper(delegate: self)
        weightTF.delegate = self
        weightTF.tintColor = UIColor.black
        messageText = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        helper.getWeightsAndDates(fromDate: Date.distantPast, toDate: Date.distantFuture)
    }
    
    @IBAction func segmentedCAction(_ sender: UISegmentedControl) {
        print("selected segment index: \(sender.selectedSegmentIndex)")
        weightDisplayUnit = WeightUnit(rawValue: sender.selectedSegmentIndex)!
        weightTF.text = ""
        updateUI()
    }
    
    // need a better name; this function receives wad from helper and stores it in viewcontroller
    func saveWeightsAndDates( wad: [ (kg: Double, date: Date) ] ) {
        weightsAndDates = wad
        updateCells()
        messageText = "\(weightsAndDates.count) weights"
    }
    
    @IBAction func saveWeightAction(_ sender: Any) {
        
        weightTF.resignFirstResponder()
        noteTF.resignFirstResponder()
        
        if let wt = (weightTF.text!).roundedDoubleFromString() {    // rounded to what precision?
            if wt > minValue(weightDisplayUnit) && wt < maxValue(weightDisplayUnit) {
                print("saving wt: \(wt), unit: \(weightDisplayUnit), note: \(noteText)")
                helper.storeWeight(kg: wt * weightDisplayUnit.unitToKgFactor(), unit: weightDisplayUnit, note: noteText)
            } else {
                weightOutOfRange()
            }
        } else {
            weightOutOfRange()
        }
        weightText = ""     // blank makes placeholder text appear
        noteText = ""   // not needed ? 
    }
    
    func didSaveWeight() {
        print("didSaveWeight    WAD.count: \(weightsAndDates.count)")
        helper.getWeightsAndDates(fromDate: Date.distantPast, toDate: Date.distantFuture)
    }
    
    func saveWeightFailed() {
        print("saveWeightFailed")
        exit(0) // will only be called during debugging
    }
    
    func weightOutOfRange() {
        print("weightOutOfRange")
        messageText = "Valid range is \( minValue(weightDisplayUnit) ) to \( maxValue(weightDisplayUnit) ) \(weightDisplayUnit.abbreviation() )"
    }
    
    func updateUI() {
        print("updateUI")
        updateCells()
    }
    
    func updateCells() {
        if tableView != nil && !weightsAndDates.isEmpty {
            tableView!.reloadData()
        } else {
            fatalError("updateCells failed; tableView is nil or weightsAndDates is empty")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weightAndDateCell", for: indexPath) as! WeightAndDateCell
        cell.updateFields(withSample: weightsAndDates[indexPath.row], displayUnit: weightDisplayUnit)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView = tableView
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(section == 0, "fatal error: tableView asks for number of rows in section \(section)")
        return weightsAndDates.count
    }
}

extension String {
    
    // returns String converted to Double with one significant decimal
    // if string doesn't convert to a number return nil
    func roundedDoubleFromString() -> Double? {
        if let x = Double(self) {
            return round(x * 10.0) / 10.0
        } else {
            return nil
        }
    }
}
