//
//  RepositoryService.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation

enum RepositoryService {
    case sampleAPI2(query: String)
}

extension RepositoryService: NetworkTargetType {
    var baseURL: String {
        return ""
    }
    
    var path: String {
        switch self {
        case .sampleAPI2:
            return "/abc/abc"
        }
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var task: NetworkTask {
        switch self {
        case let .sampleAPI2(query):
            var param: [String: Any] = [:]
            param["query"] = query
            
            return .requestParameters(parameters: param, encoding: .jsonEncoding)
        }
    }
    
    var headers: [String : String]? {
        var headers = [String: String]()
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "application/json;charset=UTF-8"
        return headers
    }
    
    func generateFailResponse(data: Data, response: NetworkResponse) -> NetworkError? {
        if let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any],
            let resultCd = dic["resultCd"] as? String, resultCd != "00000" {
            let resultMsg = (dic["resultMsg"] as? String) ?? ""
            return NetworkError.invalidNetworkError(resultCd, resultMsg, response)
        }
        return nil
    }
}
