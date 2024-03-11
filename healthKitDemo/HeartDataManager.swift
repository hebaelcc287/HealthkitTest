//
//  HeartDataManager.swift
//  healthKitDemo
//
//  Created by Heba Elcc on 11.3.2024.
//

import Foundation
import HealthKit

class HeartDataManager {
    
    let healthStore = HKHealthStore()
    
    func fetchHeartRateData() {
           let now = Date()
           let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
           
           let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictEndDate)
           
           guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
               print("Heart rate type is not available")
               return
           }
           
           let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
               guard let samples = samples as? [HKQuantitySample], error == nil else {
                   print("Error fetching heart rate data: \(error?.localizedDescription ?? "Unknown error")")
                   return
               }
               for sample in samples {
                   let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                   let date = sample.startDate
                   print("Heart Rate: \(heartRate) bpm, Date: \(date)")
               }
           }
           
           healthStore.execute(query)
       }
    
       func fetchRestingHeartRateData() {
           
           let now = Date()
           let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
           
           let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictEndDate)
           
           guard let restingHeartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
               print("Resting heart rate type is not available")
               return
           }
           
           let query = HKSampleQuery(sampleType: restingHeartRateType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
               guard let samples = samples as? [HKQuantitySample], error == nil else {
                   print("Error fetching resting heart rate data: \(error?.localizedDescription ?? "Unknown error")")
                   return
               }
               
               for sample in samples {
                   let restingHeartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                   let date = sample.startDate
                   print("Resting Heart Rate: \(restingHeartRate) bpm, Date: \(date)")
               }
           }
           
           healthStore.execute(query)
       }
    func fetchHRVSDNNData() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictEndDate)
        
        guard let hrvSDNNType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            print("Heart Rate Variability is not available")
            return
        }
           
           let query = HKSampleQuery(sampleType: hrvSDNNType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
               guard let samples = samples as? [HKQuantitySample], error == nil else {
                   print("Error fetching HRV SDNN data: \(error?.localizedDescription ?? "Unknown error")")
                   return
               }
               
               for sample in samples {
                   let hrvSDNNValue = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                   let date = sample.startDate
                   print("HRV SDNN: \(hrvSDNNValue) ms, Date: \(date)")
               }
           }
           
           healthStore.execute(query)
       }
    
    func fetchWalkingHeartRateAverage() {
          guard let walkingHeartRateAverageType = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage) else {
              print("Walking heart rate average type is not available")
              return
          }
          
          let query = HKStatisticsQuery(quantityType: walkingHeartRateAverageType, quantitySamplePredicate: nil, options: .discreteAverage) { (query, result, error) in
              guard let result = result, error == nil else {
                  print("Error fetching walking heart rate average data: \(error?.localizedDescription ?? "Unknown error")")
                  return
              }
              
              if let averageHeartRate = result.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) {
                  print("Walking Heart Rate Average: \(averageHeartRate) bpm")
              } else {
                  print("Unable to calculate walking heart rate average")
              }
          }
          
          healthStore.execute(query)
      }
   
}
