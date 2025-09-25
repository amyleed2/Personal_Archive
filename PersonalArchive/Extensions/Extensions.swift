//
//  Extensions.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import UIKit

// MARK : Extension of UIColor
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha:CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    convenience init(rgb: Int,_ alpha:CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
}

// MARK : Extension of FileManager
extension FileManager {
    // 하위 폴더 모두 삭제
    static func deleteDirectory(_ folderName:String) throws {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let folder = dir.appendingPathComponent(folderName)
                let dirList = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
                
                for d in dirList {
                    try FileManager.default.removeItem(at: d)
                }
            } catch (let e){
                throw e
            }
        }
    }
        
    // 파일패스 가져오기
    static func getPathInDirectory(_ folderName:String) throws -> String? {
        
        var path:String?
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let folder = dir.appendingPathComponent(folderName)
                let dirList = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
                
                for d in dirList {
                    if !d.absoluteString.hasSuffix(".DS_Store"){
                        let fileList = try FileManager.default.contentsOfDirectory(at: d, includingPropertiesForKeys: nil, options: [])
                        for f in fileList {
                            path = f.path
                        }
                    }
                }
                
            } catch (let e){
                throw e
            }
        }
        
        return path
    }
    
    /*
     파일 저장
     - author: ezyeun
     - parameter folderName: 파일을 저장할 폴더명
     - parameter fileName: 저장될 파일명
     - parameter data: 저장될 데이터
     */
    static func saveFile(_ folderName:String, _ fileName:String,  _ data:Data) throws {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let folder = dir.appendingPathComponent(folderName)
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
                
                let file = folder.appendingPathComponent(fileName)
                try data.write(to: file)
                
            } catch (let e){
                throw e
            }
        }
    }
    
    // 파일 불러오기 : JSON
    static func loadJSONFile(_ fileName:String) -> [String:Any]? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let dirList = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
                
                for d in dirList {
                    if d.lastPathComponent == fileName {
                        let data = try Data(contentsOf: d)
                        //let str = try String.init(contentsOf: d)
                        // 결과값 JSON 파싱
                        if let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                            return result
                        }
                    }
                }
            } catch {
                
            }
        }
        
        return nil
    }
    
    
    /**
     This method sum two double numbers and returns.
     
     Here is the discussion. This methods adds two double and return the optional Double.
     
     - author: Jay Lee(jaehyun@gsretail.com)
     - since: 2020.06.30.
     - parameter fileName: First Double Number.
     - parameter withExtension: Second Double Number.
     - returns: Dictionary that has been loaded json from resource file.
     
     # Notes: #
     
     
     # Example #
     ```
     
     ```
     */
    static func loadJSONFileFromResource(_ fileName:String, _ withExtension:String) -> [String:Any]? {
        let filePath = Bundle.main.url(forResource: fileName, withExtension: withExtension)
        
        do {
            if let data = try? Data(contentsOf: filePath!) {
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                    return result
                }
            }
        } catch {
                
        }
        return nil
    }
    
    // 파일 존재 여부 체크
    static func checkExists(_ folderName:String) -> Bool {
        
        var flag = false
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let folder = dir.appendingPathComponent(folderName)
            flag = FileManager.default.fileExists(atPath: folder.path)
        }
        
        return flag
    }    
}


// MARK : Extension of UIDevice
extension UIDevice {
    // Model ID ex: iPhone12,1
    static var modelID:String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    // 실제 사용자가 인식하는 모델
    static var modelName: String {
        switch modelID {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,6":                              return "iPhone XS MAX"
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "iPad7,5", "iPad7,6":                      return "iPad 6"
        case "iPad8,1", "iPad8,2","iPad8,3","iPad8,4":  return "iPad Pro (3rd) 11 Inch"
        case "iPad8,5", "iPad8,6","iPad8,7","iPad8,8":  return "iPad Pro (3rd) 12.9 Inch"
        case "iPad11,1", "iPad11,2":                      return "iPad Mini 4"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return modelID
        }
    }
    
    // Network Interface type
    fileprivate enum NIType:String {
        case wifi = "en0"
        
        case wired2 = "en2"
        case wired3 = "en3"
        case wired4 = "en4"
        case wired7 = "en7"
        
        case cellular0 = "pdp_ip0"
        case cellular1 = "pdp_ip1"
        case cellular2 = "pdp_ip2"
        case cellular3 = "pdp_ip3"
    }
    
    fileprivate static func getIPAddress() -> String? {
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        var niDictionary = [NIType:String?]()
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) { let interface = ifptr.pointee
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                // Check interface name:
                if let type = NIType(rawValue: String(cString: interface.ifa_name)) {
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    niDictionary.updateValue(String(cString: hostname), forKey: type)
                }
            }
        }
        
        freeifaddrs(ifaddr)
        
        /*
         @author: junhan
         @date: 2020.05.07
         @description: SmilePay통신 시 ipv6가 들어가는 경우가있음
         - [추정] KT단말의경우 celluar1 네트워크 카드를 사용하는 듯싶음
         - 기존 테스트했던 단말(LGU+)은 cellular0 네트워크 카드에 ip가 들어있음
         */
        var result:String? = nil
        var fixedAddress:String? = nil
        for (key, val) in niDictionary {
            if let val = val {
                switch key {
                case .wifi:
                    result = val
                    break
                    
                default:
                    if val == "192.0.0.1" || val == "192.0.0.4" {
                        fixedAddress = val
                    } else {
                        result = val
                        break
                    }
                }
            }
        }
        
        // 유효한 ip값이 찾아진경우
        if let result = result {
            return result
        }
        
        // 유효한 ip가 발견되지 않았을때, 임시적으로 고정 ip라도 일단 전달함
        if let fixedAddress = fixedAddress {
            return fixedAddress
        }
        
        return result
    }
    
    // IP Address
    static var ipAddr:String? {
        return getIPAddress()
    }
}



// MARK : Extension of String
extension String {
    /// length 만큼의 랜덤 스트링
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    // 하이픈이 추가된 스트링 (01012345678 -> 010-1234-5678)
    var hypenNo:String {
        var string = ""
        guard self.count > 3 else {
            return string
        }
        
        string = self.substring(with: 0..<3)
        string += "-"
        if self.count == 10 {
            string += self.substring(with: 3..<6)
            string += "-"
            string += self.substring(with: 6..<10)
        } else if self.count == 11 {
            string += self.substring(with: 3..<7)
            string += "-"
            string += self.substring(with: 7..<11)
        } else {
            return self
        }
        
        return string
    }
    
    // Localized String
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
    
    func with(_ arg:CVarArg) -> String {
        return String(format: self, arg)
    }
    
    // Localized String with argument
    func localized(with:CVarArg) -> String{
        return String(format: localized, with)
    }
    
    // json string -> dictionary
    var dictionary:[String:Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch { }
        }
        
        return nil
    }
    
    var urlHost:String? {
        let url = URL(string: self)
        return url?.host
    }
    
    // String to Object
    func toLocalObj<T>(_ type:T.Type) -> T? where T:Decodable {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        return try? JSONDecoder().decode(type, from: data)
    }
    /// URL Encoded string
    var deeplinkUrlEncoded:String {
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: ";/?:@&=+$, ")
        return self.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) ?? self
    }
    
    /// URL Encoded string
    var urlEncoded:String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    
    var urlDecoded: String? {
        return self.removingPercentEncoding
    }
    
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    // string[start...] : include start index
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    // string[..<end] : exclude end index
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    // string[start..<end] : include start index & exclude end index
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    //""이면 false, 값이 있으면 true
    var isNotEmpty:Bool {
        get {
            return !self.isEmpty
        }
    }
    
}

extension NSString {

    class func swizzleReplacingCharacters() {
        let originalMethod = class_getInstanceMethod(
        NSString.self, #selector(NSString.replacingCharacters(in:with:)))

        let swizzledMethod = class_getInstanceMethod(
        NSString.self, #selector(NSString.swizzledReplacingCharacters(in:with:)))

        guard let original = originalMethod, let swizzled = swizzledMethod else {
            return
        }

        method_exchangeImplementations(original, swizzled)
    }

    @objc func swizzledReplacingCharacters(in range: NSRange, with replacement: String) -> String {
        return self.swizzledReplacingCharacters(in: range, with: replacement)
    }
}


extension Array {
    // first value
    var first: Element? {
        if self.count < 1 {
            return nil
        }
        
        return self[0]
    }
    
    // last value
    var last: Element? {
        if self.count < 1 {
            return nil
        }
        
        return self[endIndex - 1]
    }
    
    /// to json string
    var jsonString: String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? nil
        } catch {
            return nil
        }
    }
    
    /* split in chunks with given chunk size */
    func chunks(size chunksize: Int) -> Array<Array<Element>> {
        var words = Array<Array<Element>>()
        words.reserveCapacity(self.count / chunksize)
        for idx in stride(from: chunksize, through: self.count, by: chunksize) {
            words.append(Array(self[idx - chunksize..<idx])) // slow for large table
        }
        let reminder = self.suffix(self.count % chunksize)
        if !reminder.isEmpty {
            words.append(Array(reminder))
        }
        return words
    }
}

extension Dictionary {
    /// to json string
    var jsonString: String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? nil
        } catch {
            return nil
        }
    }
    
    // merge
    mutating func merge(_ dict: [Key: Value]?){
        guard let dict = dict else {
            return
        }
        
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
    
    
    func toObject<T>(_ type:T.Type) throws -> T? where T:Decodable {
        return try JSONDecoder().decode(type, from: JSONSerialization.data(withJSONObject: self))
    }
    
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
}



extension Data {
    // 'pretty' json string for debug
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
    
    var bytes: Array<UInt8> {
        return Array(self)
    }
}



extension Date {
    func totalDistance(from date: Date, QresultIn component: Calendar.Component) -> Int? {
        return Calendar.current.dateComponents([component], from: self, to: date).value(for: component)
    }
    
    func compare(with date: Date, only component: Calendar.Component) -> Int {
        let days1 = Calendar.current.component(component, from: self)
        let days2 = Calendar.current.component(component, from: date)
        return days1 - days2
    }
    
    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        return self.compare(with: date, only: component) == 0
    }
    
    static var nextDate:Date {
        let oneDayInSec:TimeInterval = 86400
        return Date(timeIntervalSinceNow: oneDayInSec)
    }
}


/**
 
 */
extension URL {
    
    // FIle 관련
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch _ as NSError {
            
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
    
    var queryDictionary: [String: String]? {
        guard let query = self.query, query != "" else {
            return nil
        }
        
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            
            let key = pair.components(separatedBy: "=")[0]
            
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        return queryStrings
    }
    
    var params: [String: String]? {
        if let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) {
            if let queryItems = urlComponents.queryItems {
                var params = [String: String]()
                queryItems.forEach{
                    params[$0.name] = $0.value
                }
                return params
            }
        }
        
        return nil
    }
       
    public func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var items = urlComponents.queryItems ?? []
        items += parameters.map({ URLQueryItem(name: $0, value: $1) })
        urlComponents.queryItems = items
        return urlComponents.url!
    }
}

// MARK : Extension of Int
extension Int {
    init(stringValue:String?) {
        guard let stringValue = stringValue else {
            self = 0
            return
        }
        
        self = Int(stringValue) ?? 0
    }
}

// MARK : Extension of DateFormatter
extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let pushToday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년MM월dd일 HH시mm분"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// MARK : Extension of NSObject
extension NSObject{
    var className: String {
        let classNameArr = NSStringFromClass(type(of: self)).components(separatedBy: ".")
        return classNameArr[1]
    }
}
