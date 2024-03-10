//
//  ViewController.swift
//  healthKitDemo
//
//  Created by Heba Elcc on 7.3.2024.
//
//
import UIKit
import HealthKit

@available(iOS 15.0, *)
class ViewController: UIViewController {
    
    @IBOutlet var ActivityStackView: UIStackView!
    @IBOutlet var activityTypeLabel: UILabel!
    // Step 4 : create the HealthKit dataTypes your app needs to read and write
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var stepsLabel: UILabel!
    let healthStore = HKHealthStore()
    
    
    //    let allTypes : Set = [
    //        HKQuantityType.workoutType(),
    //        HKQuantityType(.activeEnergyBurned),
    //        HKQuantityType(.distanceCycling),
    //        HKQuantityType(.distanceWalkingRunning),
    //        HKQuantityType(.distanceWheelchair),
    //        HKQuantityType(.heartRate)
    //
    //
    //    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        requestHealthKitAuthorization()
        
    }
    @IBAction func AuthorizeHealthKitButton(_ sender: Any) {
        // Ensure HealthKit Availability
        
    }
    
    func requestHealthKitAuthorization() {
        // Define the types of data to read from HealthKit
        let typesToRead: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!
        ]
        
        // Request authorization to read HealthKit data
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted")
                // Once authorization is granted, you can fetch step count and sleep data
                self.fetchStepCountDataForLastMonth()
                self.fetchSleepDataForLastDay()
//                self.fetchActiveEnergyData()
                self.fetchActiveEnergyForSpecificTimeRange()
                self.fetchWalkingRunningDistanceForToday()
                self.fetchBodyMeasurements()
                self.fetchStepCountDataForToday()

            } else {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
            }
            func fetchStepCountDataForToday() {
                // Get the calendar
                   let calendar = Calendar.current
        
                   // Specify the date for March 8, 2024
                   var dateComponents = DateComponents()
                   dateComponents.year = 2024
                   dateComponents.month = 3
                   dateComponents.day = 10
                   let march8 = calendar.date(from: dateComponents)!
        
                   // Get the start and end times for March 8, 2024
                   let startOfDay = calendar.startOfDay(for: march8)
                   let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
                // Create the predicate for the query
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
                // Define the type of data to read (step count)
                guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
                    print("Step count type is not available")
                    return
                }
        
                // Create the query to retrieve step count samples
                let query = HKStatisticsQuery(quantityType: stepCountType,
                                               quantitySamplePredicate: predicate,
                                               options: .cumulativeSum) { (query, result, error) in
                    guard let result = result, let sum = result.sumQuantity() else {
                        print("Error fetching step count data: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
        
                    let stepCount = sum.doubleValue(for: HKUnit.count())
        
                    // Create date formatter
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .short
                    dateFormatter.dateStyle = .none
                    dateFormatter.timeZone = TimeZone.current
        
                    // Format start and end times
                    let startTimeString = dateFormatter.string(from: startOfDay)
                    let endTimeString = dateFormatter.string(from: endOfDay)
        
                    // Calculate duration in days, hours, and seconds
                    let durationInSeconds = Int(endOfDay.timeIntervalSince(startOfDay))
                    let days = durationInSeconds / (24 * 3600)
                    let hours = (durationInSeconds % (24 * 3600)) / 3600
                    let seconds = durationInSeconds % 60
        
                    // Construct duration string
                    var durationString = ""
                    if days > 0 {
                        durationString += "\(days) days"
                    }
                    if hours > 0 {
                        durationString += (durationString.isEmpty ? "" : ", ") + "\(hours) hours"
                    }
                    if seconds > 0 || durationString.isEmpty {
                        durationString += (durationString.isEmpty ? "" : ", ") + "\(seconds) seconds"
                    }
        
                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        self.activityTypeLabel.text = "Steps"
                        self.stepsLabel.isHidden = false
                        self.stepsLabel.text = "Steps: \(stepCount)"
                        self.startTimeLabel.text = "Start Time: \(startTimeString)"
                        self.endTimeLabel.text = "End Time: \(endTimeString)"
                        self.durationLabel.text = "Duration: \(durationString)"
                    }
                }
        
                // Execute the query
                healthStore.execute(query)
            }
    func fetchBodyMeasurements() {
            // Define the start and end dates for the query (e.g., past 24 hours)
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

            // Create the predicate for the query
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)


            let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
            let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
                if let result = results?.first as? HKQuantitySample{
                    print("Height => \(result.quantity)")
                }else{
                    print("OOPS didnt get height \nResults => \(results), error => \(error)")
                }
            }
            self.healthStore.execute(query)
        }

    func fetchWalkingRunningDistanceForToday() {
          // Define the start and end dates for today
          let calendar = Calendar.current
          let now = Date()
          let startOfDay = calendar.startOfDay(for: now)
          let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

          // Create predicate for today's workouts
          let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

          // Define the type of data to read (distance walking and running)
          guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
              print("Distance walking/running type is not available")
              return
          }

          // Create query to retrieve distance walking/running samples
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

          // Execute the query
          healthStore.execute(query)
      }
        func fetchStepCountDataForLastMonth() {
            // Get the calendar
            let calendar = Calendar.current
            
            // Get the start and end dates for the previous month
            var currentDate = Date()
            guard let previousMonthStartDate = calendar.date(byAdding: .month, value: -1, to: calendar.startOfDay(for: currentDate)),
                  let previousMonthEndDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: currentDate)) else {
                print("Error calculating previous month dates")
                return
            }
            
            // Iterate over each day of the previous month
            currentDate = previousMonthStartDate
            while currentDate <= previousMonthEndDate {
                // Get the start and end times for the current day
                let startOfDay = calendar.startOfDay(for: currentDate)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                // Create the predicate for the query
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
                
                // Define the type of data to read (step count)
                guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
                    print("Step count type is not available")
                    return
                }
                
                // Create the query to retrieve step count samples
                let query = HKStatisticsQuery(quantityType: stepCountType,
                                              quantitySamplePredicate: predicate,
                                              options: .cumulativeSum) { (query, result, error) in
                    guard let result = result, let sum = result.sumQuantity() else {
                        print("Error fetching step count data: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    let stepCount = sum.doubleValue(for: HKUnit.count())
                    
                    // Handle the step count data as needed
                    print("Steps on \(startOfDay): \(stepCount)")
                }
                
                // Execute the query
                healthStore.execute(query)
                
                // Move to the next day
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }
        
//    func FetchActiveEnergyData(){
//        // Define the start and end dates for the query (e.g., past 24 hours)
//        let calendar = Calendar.current
//        let now = Date()
//        let startOfDay = calendar.startOfDay(for: now)
//        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
//        
//        //Create the predicate for the quary
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
//        
//        // Define the type of data to read (active energy burned)
//           guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
//               print("Active energy type is not available")
//               return
//           }
//        // Create the query to retrieve active energy samples
//
//        let query = HKSampleQuery(sampleType: activeEnergyType,
//                                      predicate: predicate,
//                                      limit: HKObjectQueryNoLimit,
//                                  sortDescriptors: nil) { (query, results, error) in
//            guard let results = results as? [HKQuantitySample], error == nil else {
//                print("Error fetching active energy data: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            
//            // Process active energy samples
//            for sample in results {
//                let value = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
//                let startDate = sample.startDate
//                let endDate = sample.endDate
//                print("Active Energy Burned: \(value) kcal, Start Date: \(startDate), End Date: \(endDate)")
//            }
//        }
//            healthStore.execute(query)
//
//    }
    

//    func fetchActiveEnergyDataForToday() {
//         let calendar = Calendar.current
//         let now = Date()
//         let startOfDay = calendar.startOfDay(for: now)
//         let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
//
//         let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
//
//         guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
//             print("Active energy type is not available")
//             return
//         }
//
//         let query = HKStatisticsQuery(quantityType: activeEnergyType,
//                                       quantitySamplePredicate: predicate,
//                                       options: .cumulativeSum) { (query, result, error) in
//             guard let result = result, let sum = result.sumQuantity() else {
//                 print("Error fetching active energy data: \(error?.localizedDescription ?? "Unknown error")")
//                 return
//             }
//
//             let activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
//
//             print("Active energy for today: \(activeEnergy) kcal")
//
//             // Now you can use the activeEnergy value as needed
//         }
//
//         healthStore.execute(query)
//     }
    func fetchActiveEnergyForSpecificTimeRange() {
        // Define the start and end dates for the query (e.g., March 9th from 2:00 PM to 3:00 PM)
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 9
        components.hour = 10 // 2:00 PM
        let startDate = calendar.date(from: components)!
        components.hour = 13 // 3:00 PM
        let endDate = calendar.date(from: components)!

        // Create the predicate for the query
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        // Define the type of data to read (active energy burned)
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Active energy type is not available")
            return
        }

        // Create the query to retrieve active energy samples
        let query = HKStatisticsQuery(quantityType: activeEnergyType,
                                       quantitySamplePredicate: predicate,
                                       options: .cumulativeSum) { (query, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Error fetching active energy data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())

            // Update UI or perform any other action with the fetched active energy data
            print("Active Energy for March 9th, 2:00 PM - 3:00 PM: \(activeEnergy) kcal")
        }

        // Execute the query
        healthStore.execute(query)
    }

    func fetchSleepDataForLastDay() {
        // Define the start and end dates for the query (past 24 hours)
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictEndDate)
        
        // Define the type of data to read (sleep analysis)
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep type is not available")
            return
        }
        
        // Create the query to retrieve sleep samples
        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { (query, results, error) in
            guard let results = results as? [HKCategorySample], error == nil else {
                print("Error fetching sleep data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Process sleep samples
            for sample in results {
                let startDate = sample.startDate
                let endDate = sample.endDate
                let value = sample.value
                let categoryValue = (value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "In Bed" : "Asleep"
                print("Sleep: \(categoryValue), Start Date: \(startDate), End Date: \(endDate)")
            }
        }
        
        // Execute the query
        healthStore.execute(query)
    }
  
  
    }

