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
    lazy var store = HKHealthStore()    // lazy var as per tutorial https://cocoacasts.com/managing-permissions-with-healthkit/
    var hkAccessRequestWasProcessed = false
    var viewController: WeightVC!
    
    func readWeightsAndDates(fromDate: Date, toDate: Date, vc: WeightVC) {
        viewController = vc
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        print("query using time zone: ", dateFormatter.timeZone.identifier)
        print("fromDate: \(fromDate),     toDate: \(toDate)")
        
        if HKHealthStore.isHealthDataAvailable() {  // only verifies we're on a device and version that implements health kit
            let bodyMassToShare = Set( [HKQuantityType.quantityType(forIdentifier: .bodyMass)!] )
            let bodyMassToRead  = Set( [HKObjectType.quantityType(forIdentifier: .bodyMass)!] )
            store.requestAuthorization(toShare: bodyMassToShare, read: bodyMassToRead) {
                (success: Bool, error: Error?) in
                print("requestAuthorization returned; success: \(success)     error: \(error.debugDescription)")
                self.accessHealthDataBase(fromDate: fromDate, toDate: toDate, vc: vc)
            }
        }
    }
    
    func accessHealthDataBase(fromDate: Date, toDate: Date, vc: WeightVC) {
        print("start accessHealthDataBase")
        
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
            print("query ran without causing fatal error")
            print("query results.count: \(results!.count)   samples.count: \(samples.count)")

            for sample in samples {
                let pounds = sample.quantity.doubleValue(for: HKUnit.pound())
                let date = sample.startDate
                vc.weightsAndDates.append( (pounds, date) )
            }
            print("after query runs: vc.weightsAndDates.count: \(vc.weightsAndDates.count)")
            self.viewController.weightsAndDatesUpdated = true
            
        }

        store.execute(query)
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
