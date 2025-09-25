//
//  AlamofireAPI.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import Alamofire
import Moya

enum AlamofireAPI: TargetType {
    case sampleAPI(query: String)
    
    var baseURL: URL {
        return URL(string: "base url")!
    }
    
    var path: String {
        switch self {
        case .sampleAPI:
            return "/sampleAPI"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var task: Task {
        switch self {
        case let .sampleAPI(query):
            var params = [String: Any]()
            params["query"] = query
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
}
