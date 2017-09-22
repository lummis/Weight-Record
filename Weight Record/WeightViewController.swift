//
//  WeightViewController.swift
//  BPW
//
//  Created by Robert Lummis on 7/5/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import UIKit
import HealthKit

class WeightVC: UIViewController, WeightAndDateDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var noteTF: UITextField!
    @IBOutlet weak var saveB: UIButton!
    
    let hks = HKHealthStore()
    var helper: HealthKitHelper!
    var tableView: UITableView? = nil
    var dateFormatter = DateFormatter()
    var fromDate: Date!
    var toDate: Date!
    var isRemoveMessageInProgress: Bool = false
    var isWeightInValidRange: Bool = false
    var weightsAndDates: [ (kg: Double, date: Date, note: String?) ]  = []
    
    var weightDisplayUnit: WeightUnit {
        get {
            return Model.shared.weightDisplayUnit
        }
    }
    
    let delayUntilFadeOut: TimeInterval = 4.0
    let fadeDuration: TimeInterval = 1.0
    
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
    
    var storeWeightSucceeded: Bool {
        get {
            return false
        }
        set {
            print("storeWeight succeeded: \(newValue)")
            if newValue == true {
                DispatchQueue.main.async {
                    self.helper.getWeightsAndDates(fromDate: Date.distantPast, toDate: Date.distantFuture)
                }
            }
        }
    }
    
    var noteText: String {
        get{
            return noteTF.text ?? ""
        }
        
        set{
            noteTF.text = newValue  // if empty show placeholder text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm"
        helper = HealthKitHelper(delegate: self)
        weightTF.delegate = self
        weightTF.tintColor = UIColor.black
        noteTF.delegate = self
        initializeWeightTF(weightDisplayUnit)
        noteText = ""
        noteText = ""
        messageText = ""
        
        // move text right a little
        noteTF.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        saveB.isEnabled = false
        helper.getWeightsAndDates(fromDate: Date.distantPast, toDate: Date.distantFuture)
        }
    
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
        
        UIView.animate(withDuration: fadeDuration,
                       delay: delayUntilFadeOut,
                       options: [.curveEaseInOut],
                       animations: { self.messageL.alpha = 0.0 },
                       completion: { finished in
                        self.messageL.text = ""
                        self.messageL.alpha = 1.0
        }
        )
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.isHighlighted = true
    }
    
    @IBAction func segmentedCAction(_ sender: UISegmentedControl) {
        Model.shared.weightDisplayUnit = WeightUnit(rawValue: sender.selectedSegmentIndex + 10)!
        initializeWeightTF(weightDisplayUnit)
        updateCells()
        emphasizeField(nil) // deemphasize all UITextFields
    }
    
    // need a better name; this function receives wad from helper and stores it in viewcontroller
    func saveAndDisplayWeights( wad: [ (kg: Double, date: Date, note: String?) ] ) {
        weightsAndDates = wad
        updateCells()
        messageText = "\(weightsAndDates.count) weights"
    }
    
    @IBAction func saveWeightAction(_ sender: Any) {
        weightTF.resignFirstResponder()
        noteTF.resignFirstResponder()
        
        if let wt = Double(weightTF.text!) {
            if wt >= minValue(weightDisplayUnit) && wt <= maxValue(weightDisplayUnit) {
                print("saving wt: \(wt), unit: \(weightDisplayUnit), note: \(noteText)")
                helper.storeWeight(kg: wt * weightDisplayUnit.unitToKgFactor(), unit: weightDisplayUnit, note: noteText)
            } else {
                print("weight not in valid range")
            }
        } else {
            print("weight not valid")
        }
        
        initializeWeightTF(weightDisplayUnit)
        noteText = ""   // not needed ?
        emphasizeField(nil) // nil means remove all empasis
    }

    func initializeWeightTF(_ unit: WeightUnit) {
        weightTF.text = unit.pluralName() + "..."
    }

    // for debugging
    func saveWeightFailed() {
        print("saveWeightFailed")
        exit(0)
    }
    
    func updateCells() {
        if tableView != nil && !weightsAndDates.isEmpty {
            tableView!.reloadData()
        } else {
            messageText = "Can't access weight in the Apple Health app. Verify that it is set to permit 'write' and 'read'."
            print("updateCells failed; tableView is nil or weightsAndDates is empty")
        }
    }
    
                // this indented section is not being used ???
                var emphasizedFields: Set<UITextField> = []
                
                // highlight field & unhighlight any other textField that may have previously been emphasized
                // if field is nil unhighlight all fields
                func emphasizeField(_ field: UITextField?) {
                    emphasizedFields.forEach(){
                        $0.layer.borderWidth = 0
                        $0.layer.borderColor = UIColor.clear.cgColor
                    }
                    if field != nil {
                        emphasizedFields.insert(field!)
                        field!.layer.borderWidth = 2
                        field!.layer.borderColor = UIColor(red: 0.0, green: 128.0/255.0, blue: 0.0, alpha: 1.0).cgColor
                    }
                }
                //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        print("prepare")
        initializeWeightTF(weightDisplayUnit)
        print(segue.identifier!)
        let svc = segue.destination as! SettingsVC
        svc.wvc = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        initializeWeightTF(weightDisplayUnit)
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
    
    // for pausing to debug
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        super.touchesBegan(touches, with: event)
        
        initializeWeightTF(weightDisplayUnit)
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
