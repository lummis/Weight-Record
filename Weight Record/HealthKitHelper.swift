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

protocol WeightAndDateAndNoteDelegate {
   var messageText: String { get set }
   var storeWeightSucceeded: Bool { get set }
   func saveWeightsAndDatesAndNotesThenDisplay( wadan: [ (kg: Double, date: Date, note: String) ] )
   func removeRequestCompleted()
}

class HealthKitHelper {
   lazy var store = HKHealthStore()    // lazy var as per tutorial https://cocoacasts.com/managing-permissions-with-healthkit/
   var delegate: WeightVC!
   
   init(delegate: WeightVC) {
      self.delegate = delegate // we need to notify delegate when response is ready
   }
   
   internal func getWeightsAndDates(fromDate: Date, toDate: Date) {
      
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
               self.delegate.messageText = "Your Apple Health app needs to be set to permit this app to use weight values"
            }
         }
      }
   }
   
   private func readWeights(fromDate: Date, toDate: Date) {
      
      // weight values in the database are always in kg
      
      guard let sampleType: HKSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
         fatalError(" *** sampleType construction should never fail ***")
      }
      let predicate = HKQuery.predicateForSamples(withStart: fromDate, end: toDate, options: [])
      let sortDescriptor: [NSSortDescriptor] = [ NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false) ]
      let query = HKSampleQuery(sampleType: sampleType,
                                predicate: predicate,
                                limit: HKObjectQueryNoLimit,
                                sortDescriptors: sortDescriptor) {
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
                                 
                                 var results: [ (kg: Double, date: Date, note: String) ]  = []
                                 for sample in samples {
                                    let kilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))  // db weight always in kilograms
                                    let date = sample.startDate
                                    var note = ""
                                    if let metaNote = sample.metadata?["note"] {
                                       note = metaNote as! String
                                    }
                                    results.append( (kilograms, date, note) )
                                 }
                                 
                                 // if following isn't on the main thread it gives:
                                 // "This application is modifying the autolayout engine from a background thread, which can lead to engine corruption and weird...."
                                 // would this be better as a "completeion: " arg?
                                 DispatchQueue.main.async {
                                    self.delegate.saveWeightsAndDatesAndNotesThenDisplay(wadan: results)
                                 }
      }
      store.execute(query)
   }
   
/*
 func removeSampleFromHKStore(sampleDate: Date)
    make query with startTime and endTime = startTime + 1, strictStartTime and strictEndTime
    relies on the sampleDate as Date being a property of table cell even though it doesn't appear in UI per se
    execute query
    on completion:
       verify that a single sample was found
       call HKDelete with the found object as arg
       on completion:
          set delegate.deletionSuceeded true or false
    
    
 For simplicity I'm assuming one delete request is outstanding at a time. Find a way around this restriction later.

The sampple date is guaranteed to be unique, at least among samples added to the DB by this app, because the date is
 automatically the date/time the user saved the weight sample into the HK store. The user doesn't set the date manually and can't change it.
*/
   
   internal func removeSampleFromHKStore(sampleDate: Date) {
      guard let sampleType: HKSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
         fatalError(" *** sampleType construction should never fail ***")
      }
      let predicate = HKQuery.predicateForSamples(withStart: sampleDate - 1.0, end: sampleDate + 2.0, options: [.strictStartDate, .strictEndDate])
      let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
         query, results, error in
         let nSamples = results?.count ?? 0
         print("+++ # samples identified: \(nSamples)")
         print(error ?? "no error")
         if nSamples == 1 {
            let sample = results!.first
            self.store.delete(sample!) {
               deleteOK, deleteError in
//               print("deleted?  ok: \(deleteOK)    error: \(debugDescription: deleteError)")
               print("delete completed")
               self.delegate.removeRequestCompleted()
            }
         } else { print("stop because other than one sample found") }
      }
      store.execute(query)
   }
   
   // weightValue arg is kilogram & healthDB weight is always in kg
   // note is not an optional; if there is no note it is stored as ""; called comment in storyboard
   internal func storeWeight(kg: Double, unit: WeightUnit, note: String) {
      let quantityType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
      let quantityUnit: HKUnit = HKUnit.gramUnit(with: .kilo)
      let quantity: HKQuantity = HKQuantity(unit: quantityUnit, doubleValue: kg)
      let now = Date()
      let meta: [String : Any]? = ["note" : note]
      let sample: HKQuantitySample = HKQuantitySample(type: quantityType, quantity: quantity, start: now, end: now, metadata: meta)
      
      store.save(sample) {
         (ok, error) in
         self.delegate.storeWeightSucceeded = ok
         print("storeWeight completed. ok: \(ok), error: \(String(describing: error))")
      }
   }
   
}
