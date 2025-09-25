//
//  StepRepositoryProtocol.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import Combine

protocol StepRepositoryProtocol {
    func fetchSteps(days: Int) -> AnyPublisher<[HealthRecordDTO], Error>
    func saveSteps(_ steps: [HealthRecordDTO])
    func deleteStep(at index: Int)
    func loadStep() -> [HealthRecordDTO]
}
