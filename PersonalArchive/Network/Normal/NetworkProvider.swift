//
//  NetworkProvider.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation

public struct NetworkProvider<Target: NetworkTargetType> {
    
    let plugin = NetworkLoggerPlugin()
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default.apply {
            $0.allowsCellularAccess = true
            $0.timeoutIntervalForRequest = 15
            $0.timeoutIntervalForResource = 300
            $0.httpMaximumConnectionsPerHost = 10
            $0.networkServiceType = .background
            $0.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        }
        return URLSession(configuration: configuration)
    }()
    
    public init() {}
    
    public func requestType<T>(_ target: Target, _ type: T.Type) async throws -> T where T : Decodable {
        
        let path = target.baseURL + target.path
        guard var urlComponents = URLComponents(string: path) else {
            throw NetworkError.invalidURLComponents
        }
        
        // ✅ method
        let taskId = randomString(length: 4)
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = target.method.rawValue
        
        // ✅ header
        if let headerField = target.headers {
            _ = headerField.map { (key, value) in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // ✅ task
        var url: URL?
        var allowNonZeroResultCd = false
        var plainBody: String? = nil
        switch target.task {
        case .requestPlain:
            url = urlComponents.url
            if url == nil { throw NetworkError.invalidURL(urlComponents.url) }
            request.url = url
            
        case .requestParameters(let parameters, let encoding, let _allowNonZeroResultCd):
            allowNonZeroResultCd = _allowNonZeroResultCd
            switch encoding {
            case .queryString:
                // parameter query
                let queryItemArray = parameters.map {
                    URLQueryItem(name: $0.key, value: $0.value as? String)
                }
                urlComponents.queryItems = queryItemArray
                url = urlComponents.url
                if url == nil { throw NetworkError.invalidURL(urlComponents.url) }
                request.url = url
                
            case .jsonEncoding:
                do {
                    let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    request.httpBody = data
                } catch {
                    throw NetworkError.parameterEncoding(error)
                }
            }
        }
        
        // ✅ response logging
        var networkError: NetworkError?
        let data:Data
        let response:URLResponse
        do {
            let result = (try await session.data(for: request))
            data = result.0
            response = result.1
        }
        catch let error {
            networkError = NetworkError.httpStatusError(0, error.localizedDescription)
            plugin.didReceive(.failure(networkError!), taskId: taskId, target: target)
            throw networkError!
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            // httpResponse로 변환 실패..
            throw NetworkError.unKnown
        }
        let validCodes = target.validationType.statusCodes
        let networkResponse = NetworkResponse(statusCode: httpResponse.statusCode, data: data, request: request, response: httpResponse)
        if validCodes.contains(httpResponse.statusCode) {
            
            // CCS응답 오류가 00000이 아니어도 유효한 값이 있는 경우가 있어 모델 디코딩을 시도한다.
            networkError = target.generateFailResponse(data: data, response: networkResponse)
            if !allowNonZeroResultCd, let networkError {
                plugin.didReceive(.failure(networkError), taskId: taskId, target: target)
                throw networkError
            }
            
            do {
                let result = try JSONDecoder().decode(type, from: data)
                plugin.didReceive(.success(networkResponse), taskId: taskId, target: target)
                return result
            }
            catch let error {
                let mappingError = NetworkError.objectMapping(error, networkResponse)
                plugin.didReceive(.failure(networkError ?? mappingError), taskId: taskId, target: target)
                throw networkError ?? mappingError
            }
        }
        else {
            // httpResponse의 statusCode가 성공(success) 범위에 들어오지 않을 경우
            networkError = NetworkError.statusCode(networkResponse)
            let error = NetworkError.underlying(networkError!, networkResponse)
            plugin.didReceive(.failure(error), taskId: taskId, target: target)
            throw error
        }
    }
    
    private func randomString(length: Int) -> String {
        let characters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var result = String()
        result.reserveCapacity(length)
        for _ in 0..<length {
            if let random = characters.randomElement() {
                result.append(random)
            }
        }
        return result
    }
}
