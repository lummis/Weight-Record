//
//  HealthKitHelperer.swift
//  following online beginner's walk through HealthKit
//
//  Created by Robert Lummis on 7/1/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitHelper {
    let store = HKHealthStore()
    var hkAccessRequestWasProcessed = false
    var viewController: WeightVC!
    
    func authorizeHealthKit() -> Bool {  // comment while adding .git
        if HKHealthStore.isHealthDataAvailable() {
            let bodyMass = Set( [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!] )
            store.requestAuthorization(toShare: bodyMass, read: bodyMass) {
                (success, error) in
                    self.hkAccessRequestWasProcessed = success
                    if success != true {
                        print("Error handling HealthStore access request, error: \(error.debugDescription)")
                    }
                    print("hk authorize was processed: \(success), error: \(error.debugDescription)")
            }
        } else { hkAccessRequestWasProcessed = false }
        
        return hkAccessRequestWasProcessed
    }
    
    func getWeightsAndDates(fromDate: Date, toDate: Date, vc: WeightVC) {
        viewController = vc
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        print("query using time zone: ", dateFormatter.timeZone.identifier)
        print("fromDate: \(fromDate),     toDate: \(toDate)")
        
        guard let sampleType: HKSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            fatalError(" *** sampleType construction should never fail ***")
        }
        let predicate = HKQuery.predicateForSamples(withStart: fromDate, end: toDate, options: [])
        let query: HKSampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {
            (theQuery, results, error) in
            if error != nil {
                print("error: ", error.debugDescription)
            } else {
                print("error is nil after query")
            }
            
            guard let samples = results as! [HKQuantitySample]? else {
                print("error: \(error.debugDescription)")
                fatalError("query failed in func 'getWeights': \(String(describing: error?.localizedDescription))" )
            }
            print("results.count: \(results!.count)   samples.count: \(samples.count)")
            
            for sample in samples {
                let pounds = sample.quantity.doubleValue(for: HKUnit.pound())
                let date = sample.startDate
                vc.weightsAndDates.append( (pounds, date) )
            }
            self.viewController.weightsAndDatesUpdated = true
            
        }
        // options arg [HKQueryOptions.strictStartDate, HKQueryOptions.strictEndDate]

        store.execute(query)
        vc.reloadTableAfterDelay()
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
