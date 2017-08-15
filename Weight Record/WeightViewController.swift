//
//  WeightViewController.swift
//  BPW
//
//  Created by Robert Lummis on 7/5/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import UIKit
import HealthKit

class WeightVC: UIViewController, UITableViewDataSource, UITableViewDelegate, WeightAndDate, UITextFieldDelegate {

    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var noteTF: UITextField!
    
    let hks = HKHealthStore()
    let minPounds = 40.0
    let maxPounds = 399.0
    var helper: HealthKitHelper!
    var tableView: UITableView? = nil
    var dateFormatter = DateFormatter()
    var fromDate: Date!
    var toDate: Date!
    var isRemoveMessageInProgress: Bool = false
    var weightsAndDates: [ (weight: Double, date: Date) ]  = []
    let delayUntilFadeOut: TimeInterval = 4.0
    let fadeDuration: TimeInterval = 1.0
    
    var messageText: String {
        get {
            return messageL.text ?? "messageText initial value"
        }
        set {
            print("debug newValue: \(newValue)    isRemoveMessageInProgress: \(isRemoveMessageInProgress)")
            // don't call fadeThenRemoveMessage if it's already in progress
            if newValue != "" && !isRemoveMessageInProgress {
                fadeThenRemoveMessage()
            }
            print("will set newValue: \(newValue)")
            messageL.text = newValue
        }
    }
    
    func fadeThenRemoveMessage() {
        print("now fadeThenRemoveMessage")
        
        UIView.animate(withDuration: fadeDuration, delay: delayUntilFadeOut, options: [.curveEaseInOut],
                       animations: { self.messageL.alpha = 0.0 },
                       completion: { finished in self.messageL.text = ""; self.messageL.alpha = 1.0; self.isRemoveMessageInProgress = false; print("fading complete") } )
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2.0
//        textField.layer.borderColor = UIColor.red as! CGColor
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
        
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm"
        
        helper = HealthKitHelper(delegate: self)
        weightTF.delegate = self
        weightTF.tintColor = UIColor.black
        
        messageText = ""
        
        helper.getWeightsAndDates(fromDate: Date.distantPast, toDate: Date.distantFuture)
    }
    
    @IBAction func saveWeightAction(_ sender: Any) {
        print("save weight action")
        
        weightTF.resignFirstResponder()
        noteTF.resignFirstResponder()
        
        if let wt = (weightTF.text!).roundedDoubleFromString() {
            if wt > minPounds && wt < maxPounds {
                print("saving pounds: \(wt), note: \(noteText)")
                helper.saveWeight(pounds: wt, note: noteText)
            } else {
                invalidWeight()
            }
        } else {
            invalidWeight()
        }
        weightText = ""     // blank makes placeholder text appear
        noteText = ""   // not needed ? 
    }
    
    func healthKitInteractionDone() {
        helper.getWeightsAndDates(fromDate: Date.distantPast, toDate: Date.distantFuture)
    }
    
    func invalidWeight() {
        print("invalid weight")
        messageText = "Valid weight range is \(minPounds) to \(maxPounds)"
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
        cell.updateFields(withSample: weightsAndDates[indexPath.row])
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
