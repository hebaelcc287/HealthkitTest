//
//  SleepDataManager.swift
//  healthKitDemo
//
//  Created by Heba Elcc on 11.3.2024.
//
import Foundation
import HealthKit

class SleepDataManager {
    
    let healthStore = HKHealthStore()
    
    func fetchSleepData() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictEndDate)
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep type is not available")
            return
        }
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, sleepSamples, error) in
            guard let sleepSamples = sleepSamples as? [HKCategorySample], error == nil else {
                print("Error fetching sleep data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for sample in sleepSamples {
                let startTime = sample.startDate
                let endTime = sample.endDate
                let sleepState = self.sleepStateToString(sample.value)
                print("Sleep State: \(sleepState), Start Time: \(startTime), End Time: \(endTime)")
            }
        }
        
        healthStore.execute(query)
    }
    
    func sleepStateToString(_ value: Int) -> String {
        if #available(iOS 16.0, *) {
            return sleepStateToStringIOS16(value)
        } else {
            return defaultSleepStateToString(value)
        }
    }
    
    @available(iOS 16.0, *)
    func sleepStateToStringIOS16(_ value: Int) -> String {
        switch value {
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            return "Awake"
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            return "Deep Sleep"
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
            return "REM Sleep"
        case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
            return "Unspecified Sleep"
        default:
            return "InBed"
        }
    }
    
    func defaultSleepStateToString(_ value: Int) -> String {
        switch value {
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            return "Awake"
        case HKCategoryValueSleepAnalysis.asleep.rawValue:
            return "Asleep"
        default:
            return "InBed"
        }
    }
}
