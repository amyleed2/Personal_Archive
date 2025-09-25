//
//  RepositoryMock.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation

public class RepositoryMock : RepositoryProtocol {
    
    init() {}
    
    func sampleAPI2(query: String) async throws -> SampleDTO {
        SampleDTO.mock()
    }
}

extension ResponseCodable {
    public static func mock(resourceName:String?=nil) -> Self {
        let url = Bundle(for: MockDummyResponse.self).url(forResource: resourceName ?? String(describing: self), withExtension: "json")
        let data = try! Data(contentsOf: url!)
        
        return try! JSONDecoder().decode(Self.self, from: data)
    }
}

// Bundle 연결을 위해 생성
public class MockDummyResponse:Codable {
    
    public static func mock<T:Codable>(resourceName:String?=nil, for:T.Type) -> T {
        let url = Bundle(for: MockDummyResponse.self).url(forResource: resourceName ?? String(describing: self), withExtension: "json")
        let data = try! Data(contentsOf: url!)
        
        return try! JSONDecoder().decode(T.self, from: data)
    }
}

public protocol ResponseCodable: Codable {
    var resultCd:String { get }
    var resultMsg:String { get }
}
