//
//  RepositoryProtocol.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation

protocol RepositoryProtocol {
    func sampleAPI2(query: String) async throws -> SampleDTO
}
