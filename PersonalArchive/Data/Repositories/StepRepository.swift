//
//  StepRepository.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Combine
import Foundation

final class StepRepository: StepRepositoryProtocol {
    func fetchSteps(days: Int) -> AnyPublisher<[HealthRecordDTO], any Error> {
        Future { [weak self] promise in
            HealthKitManager.shared.fetchSteps(for: days) { list in
                let mapped = list.map { HealthRecordDTO(step: $0.steps, date: $0.date) }
                self?.saveSteps(mapped)
                promise(.success(mapped))
            }
        }.eraseToAnyPublisher()
    }
    
    func saveSteps(_ steps: [HealthRecordDTO]) {
        UserDefaults.healthData = steps
    }
    
    func deleteStep(at index: Int) {
        var list = loadStep()
        guard list.indices.contains(index) else { return }
        list.remove(at: index)
        saveSteps(list)
    }
    
    func loadStep() -> [HealthRecordDTO] {
        return UserDefaults.healthData ?? []
    }
}
