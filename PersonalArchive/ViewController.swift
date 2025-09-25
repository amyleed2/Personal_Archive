//
//  ViewController.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    let repository = Repository()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Task {
            await fetch2()
        }
    }
    
    func fetch1() {
        APIService.sampleAPI(query: "")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
//                switch completion {
//                case .finished:
//                    break
//                case .failure(let error):
//                    //
//                }
                
            } receiveValue: { [weak self] info in
                guard let self = self else{ return }
                
            }
            .store(in: &cancellables)

    }
    
    
    @MainActor
    func fetch2() async {
        do {
            let result = try? await repository.sampleAPI2(query: "")

        } catch let error {
            
        }
    }


}

