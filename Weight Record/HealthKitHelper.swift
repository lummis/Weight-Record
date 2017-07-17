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
    var store = HKHealthStore()    // lazy var as per tutorial https://cocoacasts.com/managing-permissions-with-healthkit/
    var hkAccessRequestWasProcessed = false
    var viewController: WeightVC!
    
//    func authorizeHealthKitAccess() {
//        if HKHealthStore.isHealthDataAvailable() {  // verify we're on a device and version that handles health kit
//            let bodyMassToShare = Set( [HKQuantityType.quantityType(forIdentifier: .bodyMass)!] )
//            let bodyMassToRead  = Set( [HKObjectType.quantityType(forIdentifier: .bodyMass)!] )
//            store.requestAuthorization(toShare: bodyMassToShare, read: bodyMassToRead) {
//                (success: Bool, error: Error?) in
//                print("requestAuthorization returned; success: \(success)     error: \(error.debugDescription)")
//                self.accessHealthDataBase()
//            }
//        }
//    }
    
    func readWeightsAndDates(fromDate: Date, toDate: Date, vc: WeightVC) {
        viewController = vc
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        print("query using time zone: ", dateFormatter.timeZone.identifier)
        print("fromDate: \(fromDate),     toDate: \(toDate)")
        
        if HKHealthStore.isHealthDataAvailable() {  // verify we're on a device and version that handles health kit
            let bodyMassToShare = Set( [HKQuantityType.quantityType(forIdentifier: .bodyMass)!] )
            let bodyMassToRead  = Set( [HKObjectType.quantityType(forIdentifier: .bodyMass)!] )
            store.requestAuthorization(toShare: bodyMassToShare, read: bodyMassToRead) {
                (success: Bool, error: Error?) in
                print("requestAuthorization returned; success: \(success)     error: \(error.debugDescription)")
                self.accessHealthDataBase(fromDate: fromDate, toDate: toDate, vc: vc)
            }
        }
//        authorizeHealthKitAccess()
//        if !ok { fatalError("HealthKit access authorization failed") }
//        
//        guard let sampleType: HKSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
//            fatalError(" *** sampleType construction should never fail ***")
//        }
//        let predicate = HKQuery.predicateForSamples(withStart: fromDate, end: toDate, options: [])
//        let query: HKSampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {
//            (theQuery, results, error) in
//            if error != nil {
//                print("error: ", error.debugDescription)
//            } else {
//                print("error is nil after query")
//            }
//            
//            guard let samples = results as! [HKQuantitySample]? else {
//                print("error: \(error.debugDescription)")
//                fatalError("query failed in func 'getWeights': \(String(describing: error?.localizedDescription))" )
//            }
//            print("results.count: \(results!.count)   samples.count: \(samples.count)")
//            
//            for sample in samples {
//                let pounds = sample.quantity.doubleValue(for: HKUnit.pound())
//                let date = sample.startDate
//                vc.weightsAndDates.append( (pounds, date) )
//            }
//            self.viewController.weightsAndDatesUpdated = true
//            
//        }
//        // options arg [HKQueryOptions.strictStartDate, HKQueryOptions.strictEndDate]
//
//        store.execute(query)
//        vc.updateUI()
    }
    
    func accessHealthDataBase(fromDate: Date, toDate: Date, vc: WeightVC) {
        print("start accessHealthDataBase")
        
        guard let sampleType: HKSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            fatalError(" *** sampleType construction should never fail ***")
        }
        let predicate = HKQuery.predicateForSamples(withStart: fromDate, end: toDate, options: [])
        let query: HKSampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {
            (theQuery, results, error) in
            if error != nil {
                print("error: ", error.debugDescription)
            } else {
                print("error is nil after running query")
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
            print("vc.weightsAndDates.count: \(vc.weightsAndDates.count)")
            self.viewController.weightsAndDatesUpdated = true
            
        }
        // options arg [HKQueryOptions.strictStartDate, HKQueryOptions.strictEndDate]

        store.execute(query)
        vc.updateUI()
        
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
