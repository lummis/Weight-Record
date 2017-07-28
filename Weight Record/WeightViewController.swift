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
    @IBOutlet weak var newWeightTF: UITextField!
    
    let hks = HKHealthStore()
    let minPounds = 40.0
    let maxPounds = 399.0
    var helper: HealthKitHelper!
    var tableView: UITableView? = nil
    var dateFormatter = DateFormatter()
    var fromDate: Date!
    var toDate: Date!
    var weightsAndDates: [ (weight: Double, date: Date) ]  = []
    
    var messageText: String {
        get {
            return messageL.text ?? "messageText initial value"
        }
        set {
            messageL.text = newValue
        }
    }
    
    var newWeightText: String {
        get {
            return newWeightTF.text ?? ""
        }
        set {
            if newValue == "" {
                newWeightTF.text = "Enter new weight..."
            } else {
                newWeightTF.text = newValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm"
        fromDate = dateFormatter.date(from: "2017-Jan-01 05:00")!   // start of this year
        toDate = Date() // now
        
        helper = HealthKitHelper(delegate: self)
        newWeightTF.delegate = self
        messageText = ""
        
        helper.getWeightsAndDates(fromDate: fromDate, toDate: toDate)
    }
    
    func displayMessage(msg: String) {
        messageL.text = msg
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("should begin editing")
        return true
    }
    
    @IBAction func clearEntryAction(_ sender: Any) {
        newWeightTF.resignFirstResponder()
        newWeightText = ""
        
    }
    
    @IBAction func saveWeightAction(_ sender: Any) {
        print("save weight action")
        
        newWeightTF.resignFirstResponder()
        if let wt = Double(newWeightTF.text!) {
            if wt > minPounds && wt < maxPounds {
                saveWeight(pounds: wt, note: "blah blah")
                helper.getWeightsAndDates(fromDate: fromDate, toDate: toDate)
                updateCells()
            } else {
                invalidWeight()
            }
        } else {
            invalidWeight()
        }
        newWeightText = ""     // blank makes default text appear
    }
    
    func invalidWeight() {
        messageL.text = "valid weight range is \(minPounds) to \(maxPounds) pounds"
        
    }
    
    func saveWeight(pounds: Double, note: String) {
        print("saveWeight func with pounds: \(pounds), note: \(note)")
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

