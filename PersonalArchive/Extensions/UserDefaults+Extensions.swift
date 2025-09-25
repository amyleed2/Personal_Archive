//
//  UserDefaults+Extensions.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation

struct SampleDTO: Codable, ResponseCodable {
    var resultCd: String
    var resultMsg: String
    let title: String
}

enum UserDefaultsKeys: String {
    case a
    case b
    case c
    case healthData
}

extension UserDefaults {
    
    func set(_ value: Any?, _ key: UserDefaultsKeys) {
        set(value, forKey: key.rawValue)
        synchronize()
    }

    func set<T: Codable>(object: T, _ key: UserDefaultsKeys) {
        let josnData = try? JSONEncoder().encode(object)
        set(josnData, forKey: key.rawValue)
        synchronize()
    }

    func value(_ key: UserDefaultsKeys) -> Any? {
        return value(forKey: key.rawValue)
    }

    func string(_ key: UserDefaultsKeys) -> String? {
        return string(forKey: key.rawValue)
    }

    func bool(_ key: UserDefaultsKeys) -> Bool {
        return bool(forKey: key.rawValue)
    }

    func any<T: Codable>(objectType: T.Type, _ key: UserDefaultsKeys) -> T? {
        guard let result = value(forKey: key.rawValue) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(objectType, from: result)
    }
}

extension UserDefaults {
    
    class var a: SampleDTO? {
        set(newVal) {
            return UserDefaults.standard.set(object: newVal, .a)
        }
        get {
            return UserDefaults.standard.any(objectType: SampleDTO.self, .a)
        }
    }
    
    // Biometrics 사용여부
    class var b: Bool? {
        set(newVal) {
            return UserDefaults.standard.set(newVal, .b)
        }
        get {
            return UserDefaults.standard.bool(.b)
        }
    }
    
    class var c: String? {
        set(newVal) {
            return UserDefaults.standard.set(newVal, .c)
        }
        get {
            return UserDefaults.standard.string(.c)
        }
    }
    
    class var healthData: [HealthRecordDTO]? {
        set(newValue) {
            return UserDefaults.standard.set(object: newValue, .healthData)
        }
        get {
            return UserDefaults.standard.any(objectType: [HealthRecordDTO].self, .healthData)
        }
    }
}
