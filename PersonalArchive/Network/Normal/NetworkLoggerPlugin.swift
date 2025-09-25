//
//  NetworkLoggerPlugin.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation


public final class NetworkLoggerPlugin {
    
    static var IS_SHOW_LOG = true
    
    let endLine = """
                  ─────────────────────────────────────────────────────────────────────────────────────────────────────
                  
                  """
    
    public func willSend(_ request: URLRequest, taskId:String, target: NetworkTargetType, plainBody: String?) {
        guard Self.IS_SHOW_LOG else { return }
        
        let headers = request.allHTTPHeaderFields ?? [:]
        let url = request.url?.absoluteString ?? "nil"
        let params = request.url?.queryDictionary
        
        var requestLog:[String] = []
        requestLog.append("""
                          \n
                          ╭─🙏[REQUEST-\(taskId)][\(target.path)]──────────────────────────────────────────────────────
                          │ <willSend \(Date().debugDescription)>
                          │ url : \(url)
                          │ headers \(headers.isEmpty ? ": nil" : "")
                          """)
        headers.forEach { key, value in
            requestLog.append("|    \(key): \(value)")
        }
        requestLog.append("│ params \(params?.isEmpty ?? true ? ": nil" : "")")
        params?.forEach { key, value in
            requestLog.append("|    \(key): \(value)")
        }
#if DEBUG
        if let plainBody {
            requestLog.append("│ plain body : \(plainBody)")
        }
        if let body = request.httpBody,
           let bodyString = String(bytes: body, encoding: String.Encoding.utf8) {
            requestLog.append("│ body : \(bodyString)")
        }
#endif
        requestLog.append("╰\(endLine)")
        
        let log = requestLog.joined(separator: "\n")
        print(log)
    }
    
    public func didReceive(_ result: Result<NetworkResponse, Error>, taskId:String, target: NetworkTargetType) {
        guard Self.IS_SHOW_LOG else { return }
        
        #if DEBUG
        switch result {
        case let .success(resultResponse):
            let request = resultResponse.request
            let data = resultResponse.data
            
            let headers = request.allHTTPHeaderFields ?? [:]
            let url = request.url?.absoluteString ?? "nil"
            var bodyString = "nil"
            if let data = request.httpBody, let string = String(bytes: data, encoding: String.Encoding.utf8) {
                bodyString = string
            }
            
            let responseString = data.prettyPrintedJSONString ?? "nil"

            var responseLog:[String] = []
            responseLog.append("""
                               \n
                               ╭─✅[RESPONSE-\(taskId)][\(target.path)]──────────────────────────────────────────────────────
                               │ <didReceive \(Date().debugDescription)>
                               │ url : \(url)
                               │ headers \(headers.isEmpty ? ": nil" : "")
                               """)
            headers.forEach { key, value in
                responseLog.append("│    \(key): \(value)")
            }
            responseLog.append("""
                               │ body : \(bodyString)
                               │ response : \(responseString)
                               ╰\(endLine)
                               """)
            
            let log = responseLog.joined(separator: "\n")
            print(log)
            
        case let .failure(error):
            if let networkError = error as? NetworkError {
                let data = networkError.response?.data
                let dataString = data?.prettyPrintedJSONString ?? "nil"
                
                let requestBodyString = networkError.response?.request.httpBody?.prettyPrintedJSONString ?? "nil"
                              
                let log = """
                          \n
                          ╭─❌[FAIL RESPONSE-\(taskId)][\(target.path)]──────────────────────────────────────────────────────
                          │ <didReceive \(Date().debugDescription))>
                          │ requestBody : \(requestBodyString)
                          │ response : \(dataString)
                          │ error description : \(error.localizedDescription)
                          ╰\(endLine)
                          """
                
                print(log)
            } else {
                let log = """
                          \n\n
                          ╭─❌[FAIL RESPONSE-\(taskId)][\(target.path)]──────────────────────────────────────────────────────
                          │ <didReceive \(Date().debugDescription)>
                          │ error description : \(error.localizedDescription)
                          ╰\(endLine)
                          """
                
                print(log)
            }
            
            break
        }
        #endif
    }
}
