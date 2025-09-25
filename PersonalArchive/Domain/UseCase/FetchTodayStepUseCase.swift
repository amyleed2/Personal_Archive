//
//  FetchTodayStepUseCase.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Combine
import Foundation

struct FetchTodayStepUseCase {
    let repositry: StepRepositoryProtocol
    
    init(repository: StepRepositoryProtocol) {
        self.repositry = repository
    }
    
    func execute() -> AnyPublisher<HealthRecordDTO, Error> {
        repositry.fetchSteps(days: 1)
            .tryMap { $0.first ?? HealthRecordDTO(step: 0, date: Date()) }
            .eraseToAnyPublisher()
    }
}
