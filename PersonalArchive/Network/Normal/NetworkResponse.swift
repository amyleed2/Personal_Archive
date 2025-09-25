//
//  NetworkResponse.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation

public final class NetworkResponse: CustomDebugStringConvertible, Equatable {

    /// The status code of the response.
    public let statusCode: Int

    /// The response data.
    public let data: Data

    /// The original URLRequest for the response.
    public let request: URLRequest

    /// The HTTPURLResponse object.
    public let response: HTTPURLResponse?

    public init(statusCode: Int, data: Data, request: URLRequest, response: HTTPURLResponse? = nil) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
    }

    public var description: String {
        "Status Code: \(statusCode), Data Length: \(data.count)"
    }

    public var debugDescription: String { description }

    public static func == (lhs: NetworkResponse, rhs: NetworkResponse) -> Bool {
        lhs.statusCode == rhs.statusCode
            && lhs.data == rhs.data
            && lhs.response == rhs.response
    }
}
