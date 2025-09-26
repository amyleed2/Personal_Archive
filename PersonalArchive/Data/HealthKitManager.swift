//
//  HealthKitManager.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import HealthKit
import Combine

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()
    private init() {}
    
    enum HealthKitError: Error {
        case healthDataUnavailable
        case invalidStartDate
        case noResults
        case deinitialized
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { completion(false); return }
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        store.requestAuthorization(toShare: [sleepType], read: [stepType]) { success, _ in completion(success) }
    }
    
    func fetchStepsPublisher(for days: Int) -> AnyPublisher<[(date: Date, steps: Int)], Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(HealthKitError.deinitialized))
                return
            }
            guard HKHealthStore.isHealthDataAvailable() else {
                promise(.failure(HealthKitError.healthDataUnavailable))
                return
            }
            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let now = Date()
            guard let startDate = Calendar.current.date(byAdding: .day, value: -days+1, to: now) else {
                promise(.failure(HealthKitError.invalidStartDate))
                return
            }
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
            var interval = DateComponents(); interval.day = 1
            let anchorDate = Calendar.current.startOfDay(for: startDate)
            let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                    quantitySamplePredicate: predicate,
                                                    options: .cumulativeSum,
                                                    anchorDate: anchorDate,
                                                    intervalComponents: interval)
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                var output: [(Date, Int)] = []
                guard let stats = results else {
                    promise(.failure(HealthKitError.noResults))
                    return
                }
                stats.enumerateStatistics(from: startDate, to: now) { stat, _ in
                    if let quantity = stat.sumQuantity() {
                        output.append((stat.startDate, Int(quantity.doubleValue(for: HKUnit.count()))))
                    }
                }
                promise(.success(output))
            }
            self.store.execute(query)
        }
        .eraseToAnyPublisher()
    }
    
    func fetchSteps(for days: Int, completion: @escaping ([(date: Date, steps: Int)]) -> Void) {
        var token: AnyCancellable?
        token = fetchStepsPublisher(for: days)
            .replaceError(with: [])
            .sink { [weak self] values in
                completion(values)
                if let t = token {
                    self?.cancellables.remove(t)
                }
            }
        if let t = token {
            cancellables.insert(t)
        }
    }
}
