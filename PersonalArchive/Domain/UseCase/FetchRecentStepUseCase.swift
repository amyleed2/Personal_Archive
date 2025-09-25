//
//  FetchRecentStepUseCase.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Combine

struct FetchRecentStepUseCase {
    private let repository: StepRepositoryProtocol
    
    init(repository: StepRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[HealthRecordDTO], Error> {
        repository.fetchSteps(days: 7)
    }
}
