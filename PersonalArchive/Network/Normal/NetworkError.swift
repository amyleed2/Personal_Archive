//
//  NetworkError.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation

public enum NetworkError: Error {
    case unKnown
    case networkConnectError
    // ✅ Request Error
    /// url component가 invalid 할 때
    case invalidURLComponents
    /// url이 올바르지 않을 때
    case invalidURL(_ url: URL?)
    /// Indicates that an `Endpoint` failed to encode the parameters for the `URLRequest`.
    case parameterEncoding(Swift.Error)
    
    // ✅ Response Error
    case httpStatusError(_ statusCode: Int, _ resultMsg: String)
    /// resultCd != "0000"
    case invalidNetworkError(_ resultCd:String, _ resultMsg: String, _ response:NetworkResponse?)
    /// Indicates a response failed to map to a Decodable object.
    case objectMapping(Swift.Error, NetworkResponse)
    /// Indicates a response failed with an invalid HTTP status code.
    case statusCode(NetworkResponse)
    /// Indicates a response failed due to an underlying `Error`.
    case underlying(Swift.Error, NetworkResponse?)
}

public extension NetworkError {
    /// Depending on error type, returns a `Response` object.
    var response: NetworkResponse? {
        switch self {
        case .unKnown: return nil
        case .networkConnectError: return nil
        case .invalidURL: return nil
        case .invalidURLComponents: return nil
        case .parameterEncoding: return nil
        case .httpStatusError: return nil
        case .invalidNetworkError(_, _, let response): return response
        case .objectMapping(_, let response): return response
        case .statusCode(let response): return response
        case .underlying(_, let response): return response
        }
    }

    /// Depending on error type, returns an underlying `Error`.
    internal var underlyingError: Swift.Error? {
        switch self {
        case .unKnown: return nil
        case .networkConnectError: return nil
        case .invalidURLComponents: return nil
        case .invalidURL: return nil
        case .parameterEncoding(let error): return error
        case .httpStatusError: return nil
        case .invalidNetworkError: return nil
        case .objectMapping(let error, _): return error
        case .statusCode: return nil
        case .underlying(let error, _): return error
        }
    }
}

// MARK: - Error Descriptions
extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unKnown:
            return "unknown error.."
        case .networkConnectError:
            return "Please check your network connection and try again."
        case .invalidURLComponents:
            return "invalid url components"
        case .invalidURL(let url):
            return "invalid url error : \(url?.absoluteString ?? "")"
        case .parameterEncoding(let error):
            return "Failed to encode parameters for URLRequest. \(error.localizedDescription)"
        case .httpStatusError(let code, let msg):
            return "http error -> statusCode : \(code), resultMessage : \(msg)"
        case .invalidNetworkError(let resultCd, let resultMsg, let response):
            return "\(resultMsg)"
        case .objectMapping:
            return "Failed to map data to a Decodable object."
        case .statusCode(let response):
            return "Status code didn't fall within the given range. (http status code : \(response.statusCode))"
        case .underlying(let error, _):
            return error.localizedDescription
        }
    }
}
