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
    let energyDataManager = EnergyDataManager() 
    let heartDataManager = HeartDataManager()
    
    let sleepDataManager = SleepDataManager()
    let workoutDataManager = WorkoutDataManager()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        requestHealthKitAuthorization()
        
    }
    @IBAction func AuthorizeHealthKitButton(_ sender: Any) {
        // Ensure HealthKit Availability
        
    }
    
    func requestHealthKitAuthorization() {
        let typesToRead: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        ]
        
        // Request authorization to read HealthKit data
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted")
                // Once authorization is granted, you can fetch step count and sleep data
                self.sleepDataManager.fetchSleepData()
                self.workoutDataManager.fetchDistanceCyclingData()
                self.workoutDataManager.fetchWalkingRunningDistanceForToday()
                self.fetchBodyMeasurements()
                self.fetchStepCountDataForToday()
                self.heartDataManager.fetchHeartRateData()
                self.heartDataManager.fetchRestingHeartRateData()
                self.heartDataManager.fetchHRVSDNNData()
                self.heartDataManager.fetchWalkingHeartRateAverage()
                self.energyDataManager.fetchEnergyDataForToday()

            } else {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
            }
//            func fetchStepCountDataForToday() {
//                   let calendar = Calendar.current
//                   var dateComponents = DateComponents()
//                   dateComponents.year = 2024
//                   dateComponents.month = 3
//                   dateComponents.day = 11
//                   let march8 = calendar.date(from: dateComponents)!
//        
//                   let startOfDay = calendar.startOfDay(for: march8)
//                   let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
//        
//                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
//        
//                // Define the type of data to read (step count)
//                guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
//                    print("Step count type is not available")
//                    return
//                }
//        
//                // Create the query to retrieve step count samples
//                let query = HKStatisticsQuery(quantityType: stepCountType,
//                                               quantitySamplePredicate: predicate,
//                                               options: .cumulativeSum) { (query, result, error) in
//                    guard let result = result, let sum = result.sumQuantity() else {
//                        print("Error fetching step count data: \(error?.localizedDescription ?? "Unknown error")")
//                        return
//                    }
//        
//                    let stepCount = sum.doubleValue(for: HKUnit.count())
//        
//                    // Create date formatter
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.timeStyle = .short
//                    dateFormatter.dateStyle = .none
//                    dateFormatter.timeZone = TimeZone.current
//        
//                    // Format start and end times
//                    let startTimeString = dateFormatter.string(from: startOfDay)
//                    let endTimeString = dateFormatter.string(from: endOfDay)
//        
//                    // Calculate duration in days, hours, and seconds
//                    let durationInSeconds = Int(endOfDay.timeIntervalSince(startOfDay))
//                    let days = durationInSeconds / (24 * 3600)
//                    let hours = (durationInSeconds % (24 * 3600)) / 3600
//                    let seconds = durationInSeconds % 60
//        
//                    // Construct duration string
//                    var durationString = ""
//                    if days > 0 {
//                        durationString += "\(days) days"
//                    }
//                    if hours > 0 {
//                        durationString += (durationString.isEmpty ? "" : ", ") + "\(hours) hours"
//                    }
//                    if seconds > 0 || durationString.isEmpty {
//                        durationString += (durationString.isEmpty ? "" : ", ") + "\(seconds) seconds"
//                    }
//        
//                    // Update UI on the main thread
//                    DispatchQueue.main.async {
//                        self.activityTypeLabel.text = "Steps"
//                        self.stepsLabel.isHidden = false
//                        self.stepsLabel.text = "Steps: \(stepCount)"
//                        self.startTimeLabel.text = "Start Time: \(startTimeString)"
//                        self.endTimeLabel.text = "End Time: \(endTimeString)"
//                        self.durationLabel.text = "Duration: \(durationString)"
//                    }
//                }
//        
//                // Execute the query
//                healthStore.execute(query)
//            }
    
     func fetchStepCountDataForToday() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            print("Step count type is not available")
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
            guard let result = result, error == nil else {
                print("Error fetching step count data for today: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let sum = result.sumQuantity() {
                let stepCount = sum.doubleValue(for: HKUnit.count())
                print("Step Count for Today: \(stepCount)")
            } else {
                print("No step count data available for today")
            }
        }
        
        healthStore.execute(query)
    }
   
    func fetchBodyMeasurements() {
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

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

   
        func fetchStepCountDataForLastMonth() {
            let calendar = Calendar.current
            
            var currentDate = Date()
            guard let previousMonthStartDate = calendar.date(byAdding: .month, value: -1, to: calendar.startOfDay(for: currentDate)),
                  let previousMonthEndDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: currentDate)) else {
                print("Error calculating previous month dates")
                return
            }
            
            currentDate = previousMonthStartDate
            while currentDate <= previousMonthEndDate {
                let startOfDay = calendar.startOfDay(for: currentDate)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
                
                guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
                    print("Step count type is not available")
                    return
                }
                
                let query = HKStatisticsQuery(quantityType: stepCountType,
                                              quantitySamplePredicate: predicate,
                                              options: .cumulativeSum) { (query, result, error) in
                    guard let result = result, let sum = result.sumQuantity() else {
                        print("Error fetching step count data: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    let stepCount = sum.doubleValue(for: HKUnit.count())
                    
                    print("Steps on \(startOfDay): \(stepCount)")
                }
                
                healthStore.execute(query)
                
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
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

