//
//  WorkoutDataManager.swift
//  healthKitDemo
//
//  Created by Heba Elcc on 11.3.2024.
//

import Foundation
import HealthKit
class WorkoutDataManager{
    let healthStore = HKHealthStore()
    func fetchWalkingRunningDistanceForToday() {
          let calendar = Calendar.current
          let now = Date()
          let startOfDay = calendar.startOfDay(for: now)
          let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

          let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

          guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
              print("Distance walking/running type is not available")
              return
          }

          let query = HKStatisticsQuery(quantityType: distanceType,
                                         quantitySamplePredicate: predicate,
                                         options: .cumulativeSum) { (query, result, error) in
              guard let result = result else {
                  print("Error fetching distance data: \(error?.localizedDescription ?? "Unknown error")")
                  return
              }

              if let walkingRunningDistance = result.sumQuantity() {
                  let distanceInMeters = walkingRunningDistance.doubleValue(for: HKUnit.meter())
                  let distanceInKilometers = distanceInMeters / 1000.0
                  print("Total walking/running distance for today: \(distanceInKilometers) kilometers")
              } else {
                  print("No walking/running distance data available for today")
              }
          }

          healthStore.execute(query)
      }
    func fetchDistanceCyclingData() {
          let now = Date()
          let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
          
          let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictEndDate)
          
          guard let distanceCyclingType = HKObjectType.quantityType(forIdentifier: .distanceCycling) else {
              print("Distance cycling type is not available")
              return
          }
          
          let query = HKSampleQuery(sampleType: distanceCyclingType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, distanceCyclingSamples, error) in
              guard let distanceCyclingSamples = distanceCyclingSamples as? [HKQuantitySample], error == nil else {
                  print("Error fetching distance cycling data: \(error?.localizedDescription ?? "Unknown error")")
                  return
              }
              
              for sample in distanceCyclingSamples {
                  let startTime = sample.startDate
                  let endTime = sample.endDate
                  let distanceCycled = sample.quantity.doubleValue(for: HKUnit.meter())
                  let distanceInKilometers = distanceCycled / 1000.0
                  print("Start Time: \(startTime), End Time: \(endTime), Distance Cycled: \(distanceInKilometers) kilometers")
              }
          }
          
          healthStore.execute(query)
      }
}
