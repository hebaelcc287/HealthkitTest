//
//  EnergyDataManager.swift
//  healthKitDemo
//
//  Created by Heba Elcc on 11.3.2024.
import Foundation
import HealthKit

class EnergyDataManager {
    
    let healthStore = HKHealthStore()
    
    func fetchEnergyDataForToday() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
              let basalEnergyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) else {
            print("Active or basal energy type is not available")
            return
        }
        
        // Dispatch group to synchronize the execution of queries
        let queryGroup = DispatchGroup()
        
        var totalActiveEnergy: Double = 0.0
        var totalBasalEnergy: Double = 0.0
        
        // Enter the group before executing queries
        queryGroup.enter()
        let activeEnergyQuery = HKSampleQuery(sampleType: activeEnergyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, activeEnergySamples, error) in
            defer {
                // Leave the group after the query completes
                queryGroup.leave()
            }
            
            guard let activeEnergySamples = activeEnergySamples as? [HKQuantitySample], error == nil else {
                print("Error fetching active energy data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for sample in activeEnergySamples {
                let activeEnergy = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
                totalActiveEnergy += activeEnergy
            }
        }
        
        // Enter the group before executing queries
        queryGroup.enter()
        let basalEnergyQuery = HKSampleQuery(sampleType: basalEnergyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, basalEnergySamples, error) in
            defer {
                // Leave the group after the query completes
                queryGroup.leave()
            }
            
            guard let basalEnergySamples = basalEnergySamples as? [HKQuantitySample], error == nil else {
                print("Error fetching basal energy data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for sample in basalEnergySamples {
                let basalEnergy = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
                totalBasalEnergy += basalEnergy
            }
        }
        
        // Execute both queries asynchronously
        healthStore.execute(activeEnergyQuery)
        healthStore.execute(basalEnergyQuery)
        
        // Notify when all queries in the group have completed
        queryGroup.notify(queue: .main) {
            print("Total Active Energy Burned Today: \(totalActiveEnergy) kcal")
            print("Total Basal Energy Burned Today: \(totalBasalEnergy) kcal")
        }
    }
}
