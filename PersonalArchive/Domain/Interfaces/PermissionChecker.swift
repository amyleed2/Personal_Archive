//
//  PermissionChecker.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/26/25.
//

import Foundation


enum PermissionType: String {
    case contacts       = "Contacts"
    case camera         = "Camera"
    case photos         = "Photos"
    case location       = "Location"
    case notifications  = "Notifications"
    case calendar       = "Calendar"
    case microphone     = "Microphone"
    case bluetooth      = "Bluetooth"
    case biometry       = "Biometry"
    case health         = "Health"
    case idfa           = "IDFA"
}

enum PermissionStatus: String {
    case authorized    = "Authorized"
    case denied        = "Denied"
    case disabled      = "Disabled"
    case notDetermined = "Not Determined"
}


protocol PermissionChecker {
    func status(for type: PermissionType) -> PermissionStatus
    func request(for type: PermissionType, completion: @escaping (PermissionStatus) -> Void)
}
