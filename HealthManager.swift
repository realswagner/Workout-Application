//
//  HealthManager.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/26.
//

import HealthKit
import Foundation

extension Date { //Extension to establish 'today' for step and calorie start time
    static var startOfDay: Date {
        Calendar.current.startOfDay(for:Date())
    }
}

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var activities: [String : Activity] = [:]
    @Published var stepCount: Double = 0.0
    
    func requestAuthorization() {
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calories = HKQuantityType(.activeEnergyBurned)
        let healthTypes: Set = [steps, calories]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
            } catch {
                print("Error fetching health data: \(error)")
            }
        }
    }
    
    func fetchTodaySteps(){ //fetches daily step values from health app
        let steps = HKQuantityType(.stepCount)
//        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else{
                print("error fetching todays step data")
                return
            }
            let stepCount = quantity.doubleValue(for: .count())
            self.stepCount = stepCount
            let stepActivity = Activity(id: 0, title: "Todays Steps", subtitle: "Goal 10,000", cardImage: "figure.walk", amount: stepCount.formattedString(), type: .steps)
            DispatchQueue.main.sync {
                self.activities["Today's Steps"] = stepActivity
            }
//            print(stepCount)
        }
        healthStore.execute(query)
    }
    
    func fetchTodayCalories() { //fetches daily calorie (active energy burned) from health app
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else{
                print("error fetching todays calorie data")
                return
            }
            let caloriesBurned = quantity.doubleValue(for: .kilocalorie())
            let calorieActivity = Activity(id: 1, title: "Today's kcal Burned", subtitle: "Goal 900", cardImage: "flame", amount: caloriesBurned.formattedString(), type: .calories)
            DispatchQueue.main.sync {
                self.activities["todayCalories"] = calorieActivity
            }
        }
        healthStore.execute(query)
    }
}

extension Double { //function to format the double to string for readable display
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
