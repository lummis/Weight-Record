//
//  HealthKitHelperer.swift
//  following online beginner's walk through HealthKit
//
//  Created by Robert Lummis on 7/1/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import Foundation
import HealthKit

protocol WeightAndDate {
    var weightsAndDates: [ (weight: Double, date: Date) ] { get set }
    var messageText: String { get set }
}

class HealthKitHelper {
    lazy var store = HKHealthStore()    // lazy var as per tutorial https://cocoacasts.com/managing-permissions-with-healthkit/
    var weightVC: WeightVC!
    
    init(delegate: WeightVC) {
        weightVC = delegate // this is used to notify when response is ready
        weightVC.messageText = "HealthKitHelper init"
    }
    
    func getWeightsAndDates(fromDate: Date, toDate: Date) {
        weightVC.messageText = "testing getWeightsAndDates"
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        print("dateFormatter using time zone: ", dateFormatter.timeZone.identifier)
        print("fromDate: \(fromDate),     toDate: \(toDate)")

        if HKHealthStore.isHealthDataAvailable() {  // only verifies we're on a device and version that implements health kit
            weightVC.messageText = "HealthKit is available"
            let bodyMassToShare = Set( [HKQuantityType.quantityType(forIdentifier: .bodyMass)!] )   // 'share' means write
            let bodyMassToRead  = Set( [HKObjectType.quantityType(forIdentifier: .bodyMass)!] )

            store.requestAuthorization(toShare: bodyMassToShare, read: bodyMassToRead) {
                // completion block is called after the user responds to authorization request
                // success does not mean permission was granted, only that the process completed
                // if authorization was denied a subsequent request to read data will return no data
                // if authorization to share (write) was denied a subsequent request to write will fail to write
                (success: Bool, error: Error?) in
                print("requestAuthorization returned; success: \(success)     error: \(error.debugDescription)")
                if success {
                    self.weightVC.messageText = "requested HK authorization"
                    self.readWeights(fromDate: fromDate, toDate: toDate)
                } else {
                    self.weightVC.messageText = "Request HK authorization failed"
                }
            }
        }
    }
    
    func readWeights(fromDate: Date, toDate: Date) {
        print("start readWeights")
        
        guard let sampleType: HKSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            fatalError(" *** sampleType construction should never fail ***")
        }
        let predicate = HKQuery.predicateForSamples(withStart: fromDate, end: toDate, options: [])

        let query: HKSampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {
            (theQuery, results, error) in
            print("in HKSampleQuery resultsHandler")
            if error != nil {
                print("error: ", error.debugDescription)
            } else {
                print("error is nil after running query")
                
            }

            guard let samples = results as! [HKQuantitySample]? else {
                print("error: \(error.debugDescription)")
                fatalError("query failed in func 'accessHealthDataBase': \(String(describing: error?.localizedDescription))" )
            }

            print("A samples.count: \(samples.count)")
            for sample in samples {
                let pounds = sample.quantity.doubleValue(for: HKUnit.pound())
                let date = sample.startDate
                self.weightVC.weightsAndDates.append( (pounds, date) )
            }
            
            print("B samples.count: \(samples.count)")
            print("C self.weightVC.weightsAndDates.count:  \(self.weightVC.weightsAndDates.count)")
            self.displayWeightsAndDates(samples: samples)
        }
        store.execute(query)
    }
    
    func displayWeightsAndDates( samples: [HKQuantitySample] ) {
        print("displayWeightsAndDates")
        print("D samples.count: \(samples.count)")
        
        // if I don't put this on the main thread explicitly it gives:
        // "This application is modifying the autolayout engine from a background thread, which can lead to engine corruption and weird crashes etc...."
        
        DispatchQueue.main.async {
            self.weightVC.messageText = "\(self.weightVC.weightsAndDates.count) samples"
            self.weightVC.updateCells()
        }
    }

    
    func saveWeight(pounds: Double, note: String) {
        let quantityType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let quantityUnit: HKUnit = HKUnit.pound()
        let quantity: HKQuantity = HKQuantity(unit: quantityUnit, doubleValue: pounds)
        let now:Date = Date()
        
        let sample: HKQuantitySample = HKQuantitySample(type: quantityType, quantity: quantity, start: now, end: now, metadata: ["note" : note])
        
        store.save(sample) {
            (ok, error) in
            if error == nil {
                print("sample saved with no error: \(ok)")
            } else {
                print("sample saved: \(ok) with error: \(String(describing: error))")
            }
        }
    }
    
    func saveWeight(pounds: Double) {
        let quantityType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let quantityUnit: HKUnit = HKUnit.pound()
        let quantity: HKQuantity = HKQuantity(unit: quantityUnit, doubleValue: pounds)
        let now:Date = Date()
        
        let sample: HKQuantitySample = HKQuantitySample(type: quantityType, quantity: quantity, start: now, end: now)
        
        store.save(sample) {
            (ok, error) in
            if error == nil {
                print("sample saved with no error: \(ok)")
            } else {
                print("sample saved: \(ok) with error: \(String(describing: error))")
            }
        }
    }

}
