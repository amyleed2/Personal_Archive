//
//  AlamofireManager.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//


import Foundation
import Alamofire
import Moya

// MARK: Alamofire - Manager
final class AlamofireManager {
    static let manager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 300
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.networkServiceType = .background
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.requestCachePolicy = .useProtocolCachePolicy

        let manager = Session(configuration: configuration)

        return manager
    }()
}
