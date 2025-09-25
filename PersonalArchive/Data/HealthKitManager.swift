//
//  HealthKitManager.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { completion(false); return }
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        store.requestAuthorization(toShare: nil, read: [stepType]) { success, _ in completion(success) }
    }
    
    func fetchSteps(for days: Int, completion: @escaping ([(date: Date, steps: Int)]) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -days+1, to: now) else {
            completion([]); return
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        var interval = DateComponents(); interval.day = 1
        let anchorDate = Calendar.current.startOfDay(for: startDate)
        let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        query.initialResultsHandler = { _, results, _ in
            var output: [(Date, Int)] = []
            guard let stats = results else { completion([]); return }
            stats.enumerateStatistics(from: startDate, to: now) { stat, _ in
                if let quantity = stat.sumQuantity() {
                    output.append((stat.startDate, Int(quantity.doubleValue(for: HKUnit.count()))))
                }
            }
            completion(output)
        }
        store.execute(query)
    }
}

