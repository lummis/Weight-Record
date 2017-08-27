//
//  HealthKitHelperer.swift
//  following online beginner's walk through HealthKit
//
//  Created by Robert Lummis on 7/1/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//
import Foundation
import UIKit
import HealthKit

protocol WeightAndDateProtocol {
    var messageText: String { get set }
    var storeWeightSucceeded: Bool { get set }
    func saveAndDisplayWeights( wad: [ (kg: Double, date: Date) ] )
}

class HealthKitHelper {
    lazy var store = HKHealthStore()    // lazy var as per tutorial https://cocoacasts.com/managing-permissions-with-healthkit/
    var delegate: WeightVC!
    
    init(delegate: WeightVC) {
        self.delegate = delegate // this is used to notify when response is ready
    }
    
    func getWeightsAndDates(fromDate: Date, toDate: Date) {

        if HKHealthStore.isHealthDataAvailable() {  // only verifies we're on a device and version that implements health kit
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
                    self.readWeights(fromDate: fromDate, toDate: toDate)
                } else {
                    self.delegate.messageText = "Your Apple Health app does not permit this app to use weight"
                }
            }
        }
    }
    
    func readWeights(fromDate: Date, toDate: Date) {
        
        // weight values in the database are always in kg
        
        guard let sampleType: HKSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            fatalError(" *** sampleType construction should never fail ***")
        }
        let predicate = HKQuery.predicateForSamples(withStart: fromDate, end: toDate, options: [])
        let sortDescriptor: [NSSortDescriptor] = [ NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false) ]
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sortDescriptor) {
            (theQuery, results, error) in
            if error != nil {
                print("error: ", error.debugDescription)
            } else {
                print("query completed, error is nil")
            }

            guard let samples = results as! [HKQuantitySample]? else {
                print("error: \(error.debugDescription)")
                fatalError("query failed in func 'readWeights': \(String(describing: error?.localizedDescription))" )
            }

            var results: [ (kg: Double, date: Date) ]  = []
            for sample in samples {
                let kilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))  // db weight always in kilograms
                let date = sample.startDate
                results.append( (kilograms, date) )
            }
            // if following isn't on the main thread it gives:
            // "This application is modifying the autolayout engine from a background thread, which can lead to engine corruption and weird...."
            // would this be better as a "completeion: " arg?
            DispatchQueue.main.async {
                self.delegate.saveAndDisplayWeights(wad: results)
            }
        }
        
        store.execute(query)
    }
    
    // weightValue arg is kilogram & healthDB weight is always in kg
    func storeWeight(kg: Double, unit: WeightUnit, note: String) {
        let quantityType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let quantityUnit: HKUnit = HKUnit.gramUnit(with: .kilo)
        let quantity: HKQuantity = HKQuantity(unit: quantityUnit, doubleValue: kg)
        // now quantityUnit and weightValueInKilograms are unresolved identifiers
        let now = Date()
        let sample: HKQuantitySample = HKQuantitySample(type: quantityType, quantity: quantity, start: now, end: now, metadata: ["note" : note])
        store.save(sample) {
            (ok, error) in
            self.delegate.storeWeightSucceeded = ok
            print("storeWeight completed. ok: \(ok), error: \(String(describing: error))")
        }
    }
    
}
