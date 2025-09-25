//
//  NetworkTargetType.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation

public protocol NetworkTargetType {
    /// ✔ 서버의 base URL
    var baseURL: String { get }

    /// ✔ 서버의 base URL 뒤에 추가될 path
    var path: String { get }

    /// ✔ HTTP Method (get, post, put, delete 등)
    var method: HTTPMethod { get }

    /// ✔ request에 사용되는 파리미터 설정
    var task: NetworkTask { get }

    /// ✔ HTTP headers
    var headers: [String: String]? { get }
    
    /// http status code가 valid한 code인지 판별
    var validationType: ValidationType { get }
    
    /// 서버 응답코드가 성공이 아닌 경우 에러객체 생성
    func generateFailResponse(data:Data, response:NetworkResponse) -> NetworkError?
}

public extension NetworkTargetType {
    var validationType: ValidationType { .successCodes }
}


public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    
    public static let delete = HTTPMethod(rawValue: "DELETE")
    public static let get = HTTPMethod(rawValue: "GET")
    public static let post = HTTPMethod(rawValue: "POST")
    public static let put = HTTPMethod(rawValue: "PUT")
    
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public enum NetworkTask {
    /// ✔ 추가적인 데이터를 더하지 않는다.
    case requestPlain
    /// ✔ 파라미터를 인코딩해서 request 에 더합니다.
    /// allowNonZeroResultCd : true인 경우, resultCd가 "00000"이 아니더라도 error throw가 아닌 정상 응답으로 리턴한다.
    ///   - "9.2.2. 회원가입여부" API와 같은 경우 때문에 필요한 조치
    ///   - https://wiki.onestorecorp.com/pages/viewpage.action?pageId=328730480
    case requestParameters(parameters: [String : Any], encoding: ParameterEncoding, allowNonZeroResultCd: Bool = false)
}

public enum ParameterEncoding {
    case queryString
    case jsonEncoding
}

public enum ValidationType {
    
    case none
    /// Validate success codes
    case successCodes
    /// Validate success codes and redirection codes (only 2xx and 3xx).
    case successAndRedirectCodes
    /// Validate only the given status codes.
    case customCodes([Int])

    /// The list of HTTP status codes to validate.
    var statusCodes: [Int] {
        switch self {
        case .successCodes:
            return Array(200..<300)
        case .successAndRedirectCodes:
            return Array(200..<400)
        case .customCodes(let codes):
            return codes
        case .none:
            return []
        }
    }
}

extension ValidationType: Equatable {
    public static func == (lhs: ValidationType, rhs: ValidationType) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none),
             (.successCodes, .successCodes),
             (.successAndRedirectCodes, .successAndRedirectCodes):
            return true
        case (.customCodes(let code1), .customCodes(let code2)):
            return code1 == code2
        default:
            return false
        }
    }
}
