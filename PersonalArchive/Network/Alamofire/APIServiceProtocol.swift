//
//  APIServiceProtocol.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import Combine

protocol APIServiceProtocol {
    static func sampleAPI(query: String) -> AnyPublisher<SampleDTO, Error>
}
