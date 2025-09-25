//
//  APIServiceMock.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import Combine

class APIServiceMock: APIServiceProtocol {
    static func sampleAPI(query: String) -> AnyPublisher<SampleDTO, any Error> {
        // 빈 query 체크
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Fail(error: MockError.emptyQuery).eraseToAnyPublisher()
        }
        
        return loadJson("SampleDTO")
    }
    
    
}

extension APIServiceMock {
    
    /**
     Mock json file을 가져오기 위한 load json 함수
     @Parameter :
         - filename : json file name
     */
    private static func loadJson<T: Decodable>(_ filename: String) -> AnyPublisher<T, Error> {
        Future { promise in
            guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
                promise(.failure(MockError.jsonFileNotExist))
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decodedData = try decoder.decode(T.self, from: data)
                promise(.success(decodedData))
            } catch {
                promise(.failure(MockError.objectMapping(error)))
            }
        }
        .eraseToAnyPublisher()
    }
}

enum MockError: Error {
    case jsonFileNotExist
    case objectMapping(Error)
    case emptyQuery
    
    var errorDescription: String {
        switch self {
        case .jsonFileNotExist:
            return "json file을 찾을 수 없습니다."
        case .objectMapping(let error):
            return "object mapping error : \(error.localizedDescription)"
        case .emptyQuery:
            return "검색어를 입력해주세요."
        }
    }
}
