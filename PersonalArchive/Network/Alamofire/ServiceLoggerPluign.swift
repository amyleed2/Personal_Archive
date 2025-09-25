//
//  ServiceLoggerPluign.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//


import Foundation
import Moya

public final class ServiceLoggerPluign: Moya.PluginType {
    // MARK: Plugin
    
    let requestStartLine = "\n\n ->[REQUEST]->-----------------------------------------------------------------------------------------"
    let responseStartLine = "\n\n <-[RESPONSE]<----------------------------------------------------------------------------------------"
    let endLine = """
                  ─────────────────────────────────────────────────────────────────────────────────────────────────────
                  
                  """
    
    public func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        let headers = request.request?.allHTTPHeaderFields ?? [:]
        let url = request.request?.url?.absoluteString ?? "nil"
        let path = url.replacingOccurrences(of: "\("")", with: "")
        let params = request.request?.url?.queryDictionary
        
        if let body = request.request?.httpBody {
            let bodyString = String(bytes: body, encoding: String.Encoding.utf8) ?? "nil"
            print("""
                 |\n\n ->[REQUEST][\((target.path as NSString).lastPathComponent)]->-----------------------------------------------------------------------------------------
                 | <willSend - \(path) - \(Date().debugDescription)>
                 | url: \(url)
                 | headers :
                 |   \(headers.description)
                 | params :
                 |   \(params ?? [:])
                 | body: \(bodyString)
                 |\(endLine)
                """)
        } else {
            print("""
                 |\n\n ->[REQUEST][\((target.path as NSString).lastPathComponent)]->-----------------------------------------------------------------------------------------
                 | <willSend - \(path) - \(Date().debugDescription)>
                 | url: \(url)
                 | headers :
                 |   \(headers.description)
                 | params :
                 |   \(params ?? [:])
                 | body: nil
                 |\(endLine)
                """)
        }
        #endif
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case let .success(response):
            let request = response.request
            let headers = response.response?.allHeaderFields ?? request?.allHTTPHeaderFields ?? [:]
            
            let url = request?.url?.absoluteString ?? "nil"
            let method = request?.httpMethod ?? "nil"
            let statusCode = response.statusCode
            var bodyString = "nil"
            if let data = request?.httpBody, let string = String(bytes: data, encoding: String.Encoding.utf8) {
                bodyString = string
            }
            var responseString = "nil"
            if let reString = response.data.prettyPrintedJSONString as String? {//String(bytes: data, encoding: String.Encoding.utf8) {
                responseString = reString
            }
            
            print("""
                |\n\n ->[RESPONSE][\((target.path as NSString).lastPathComponent)]->-----------------------------------------------------------------------------------------
                | <didReceive - \(method) statusCode: \(statusCode)>
                | url: \(url)
                | headers :
                |   \(headers.description)
                | body: \(bodyString)
                | response:
                |   \(responseString)
                |\(endLine)
                """)
        case let .failure(error):
            print("""
                |\n\n ->[RESPONSE][\((target.path as NSString).lastPathComponent)]->-----------------------------------------------------------------------------------------
                | error: \(error.localizedDescription )
                |\(endLine)
                """)
            break
        }
        #endif
    }
}
