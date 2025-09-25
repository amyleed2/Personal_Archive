//
//  Repository.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation

class Repository: RepositoryProtocol {
    var provider: NetworkProvider<RepositoryService>
    
    init() {
        provider = NetworkProvider<RepositoryService>()
    }
    
    func sampleAPI2(query: String) async throws -> SampleDTO {
        return try await provider.requestType(.sampleAPI2(query: query), SampleDTO.self)
    }
    
}
