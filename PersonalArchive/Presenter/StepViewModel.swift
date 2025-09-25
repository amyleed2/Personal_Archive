//
//  StepViewModel.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import Combine

final class StepViewModel {
    @Published private(set) var todayStepsText = "걸음 수 로딩중 ..."
    @Published private(set) var errorMessage: String?
    @Published private(set) var stepList: [HealthRecordDTO] = []
    
    private let repository: StepRepositoryProtocol
    private let fetchTodayStepUseCase: FetchTodayStepUseCase
    private let fetchRecentSetpUseCase: FetchRecentStepUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: StepRepositoryProtocol) {
        self.repository = repository
        self.fetchRecentSetpUseCase = FetchRecentStepUseCase(repository: repository)
        self.fetchTodayStepUseCase = FetchTodayStepUseCase(repository: repository)
        
        stepList = repository.loadStep()
        updateTodayStepsTextFromList()
    }
    
    private func updateTodayStepsTextFromList() {
        let today = Date()
        let calendar = Calendar.current
        let todaySteps = stepList.first(where: { calendar.isDate($0.date, inSameDayAs: today) })?.step ?? 0
        todayStepsText = "오늘 걸음 수: \(todaySteps)"
    }
    
    func loadTodaySteps() {
        fetchTodayStepUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] steps in
                self?.mergeAndSave(newSteps: [steps])
            }
            .store(in: &cancellables)
    }
    
    func loadRecentSteps() {
        fetchRecentSetpUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] steps in
                self?.mergeAndSave(newSteps: steps)
            }
    }
    
    func deleteStep(at index: Int) {
        repository.deleteStep(at: index)
        stepList.remove(at: index)
        updateTodayStepsTextFromList()
    }
    
    private func mergeAndSave(newSteps: [HealthRecordDTO]) {
        var merged = repository.loadStep()
        for step in newSteps {
            if let idx = merged.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: step.date) }) {
                merged[idx] = step
            } else {
                merged.append(step)
            }
        }
        merged.sort { $0.date > $1.date }
        stepList = merged
        repository.saveSteps(merged)
        updateTodayStepsTextFromList()
    }
}
