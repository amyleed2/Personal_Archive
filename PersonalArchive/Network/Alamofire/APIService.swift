//
//  APIService.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import Alamofire
import Moya
import Combine

typealias APIService = MoyaProvider<AlamofireAPI>

extension APIService: APIServiceProtocol {
    static let provider = APIService(session: AlamofireManager.manager, plugins: [ServiceLoggerPluign()])
    
    static func sampleAPI(query: String) -> AnyPublisher<SampleDTO, any Error> {
        return Future { promise in
            provider.request(.sampleAPI(query: query)) { result in
                switch result {
                case .success(let response):
                    do {
                        let sample = try response.map(SampleDTO.self)
                        promise(.success(sample))
                    } catch {
                        promise(.failure(error))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
