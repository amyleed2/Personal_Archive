//
//  iOSPermissionChecker.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/26/25.
//

import Foundation
import UIKit
import Photos
import Contacts
import UserNotifications
import CoreLocation
import EventKit
import AVFoundation
import CoreBluetooth
import LocalAuthentication
import HealthKit
import AppTrackingTransparency
import AdSupport
// Data/Permissions/iOSPermissionChecker.swift

import Foundation
import Contacts
import Photos
import AVFoundation
import CoreLocation
import EventKit
import UserNotifications
import LocalAuthentication
import HealthKit
import CoreBluetooth
import AppTrackingTransparency

final class iOSPermissionChecker: NSObject, PermissionChecker {
    
    private var locationManager: CLLocationManager?
    private var locationCompletion: ((PermissionStatus) -> Void)?
    
    private var bluetoothManager: CBPeripheralManager?
    private var bluetoothCompletion: ((PermissionStatus) -> Void)?
    
    func status(for type: PermissionType) -> PermissionStatus {
        switch type {
        case .contacts:      return mapContactsStatus()
        case .camera:        return mapCameraStatus()
        case .photos:        return mapPhotosStatus()
        case .location:      return mapLocationStatus()
        case .notifications: return mapNotificationStatus()
        case .calendar:      return mapCalendarStatus()
        case .microphone:    return mapMicrophoneStatus()
        case .bluetooth:     return mapBluetoothStatus()
        case .biometry:      return mapBiometryStatus()
        case .health:        return mapHealthStatus()
        case .idfa:          return mapAdTrackingStatus()
        }
    }
    
    func request(for type: PermissionType, completion: @escaping (PermissionStatus) -> Void) {
        switch type {
        case .contacts:
            CNContactStore().requestAccess(for: .contacts) { _, _ in
                completion(self.mapContactsStatus())
            }
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { _ in
                completion(self.mapCameraStatus())
            }
        case .photos:
            PHPhotoLibrary.requestAuthorization { _ in
                completion(self.mapPhotosStatus())
            }
        case .location:
            locationCompletion = completion
            let manager = CLLocationManager()
            manager.delegate = self
            locationManager = manager
            manager.requestWhenInUseAuthorization()
        case .notifications:
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                completion(granted ? .authorized : .denied)
            }
        case .calendar:
            EKEventStore().requestAccess(to: .event) { granted, error in
                if error != nil {
                    completion(.notDetermined)
                } else {
                    completion(granted ? .authorized : .denied)
                }
            }
        case .microphone:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                completion(granted ? .authorized : .denied)
            }
        case .bluetooth:
            bluetoothCompletion = completion
            bluetoothManager = CBPeripheralManager(delegate: self, queue: nil)
        case .biometry:
            let context = LAContext()
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Biometric auth") { success, error in
                if error != nil {
                    completion(.notDetermined)
                } else {
                    completion(success ? .authorized : .denied)
                }
            }
        case .health:
            let healthStore = HKHealthStore()
            // 실제 프로젝트에서는 읽기/쓰기 타입을 지정해야 함
            healthStore.requestAuthorization(toShare: [], read: []) { granted, error in
                if error != nil {
                    completion(.notDetermined)
                } else {
                    completion(granted ? .authorized : .denied)
                }
            }
        case .idfa:
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { _ in
                    completion(self.mapAdTrackingStatus())
                }
            } else {
                completion(.disabled)
            }
        }
    }
}

// MARK: - Status Mapping
extension iOSPermissionChecker {
    
    func mapContactsStatus() -> PermissionStatus {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized: return .authorized
        case .denied, .restricted: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .disabled
        }
    }
    
    func mapCameraStatus() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return .authorized
        case .denied, .restricted: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .disabled
        }
    }
    
    func mapPhotosStatus() -> PermissionStatus {
        if #available(iOS 14, *) {
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            case .authorized, .limited: return .authorized
            case .denied, .restricted:  return .denied
            case .notDetermined:        return .notDetermined
            @unknown default:           return .disabled
            }
        } else {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:           return .authorized
            case .denied, .restricted:  return .denied
            case .notDetermined:        return .notDetermined
            @unknown default:           return .disabled
            }
        }
    }
    
    func mapLocationStatus() -> PermissionStatus {
        if #available(iOS 14, *) {
            let status = CLLocationManager().authorizationStatus
            switch status {
            case .authorizedAlways, .authorizedWhenInUse: return .authorized
            case .denied, .restricted: return .denied
            case .notDetermined: return .notDetermined
            @unknown default: return .disabled
            }
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse: return .authorized
            case .denied, .restricted: return .denied
            case .notDetermined: return .notDetermined
            @unknown default: return .disabled
            }
        }
    }
    
    func mapNotificationStatus() -> PermissionStatus {
        let registered = UIApplication.shared.isRegisteredForRemoteNotifications
        return registered ? .authorized : .denied
    }
    
    func mapCalendarStatus() -> PermissionStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized: return .authorized
        case .denied, .restricted: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .disabled
        }
    }
    
    func mapMicrophoneStatus() -> PermissionStatus {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted: return .authorized
        case .denied: return .denied
        case .undetermined: return .notDetermined
        @unknown default: return .disabled
        }
    }
    
    func mapBluetoothStatus() -> PermissionStatus {
        switch CBPeripheralManager.authorizationStatus() {
        case .authorized: return .authorized
        case .denied, .restricted: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .disabled
        }
    }
    
    func mapBiometryStatus() -> PermissionStatus {
        var error: NSError?
        let available = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return available ? .authorized : .denied
    }
    
    func mapHealthStatus() -> PermissionStatus {
        return HKHealthStore.isHealthDataAvailable() ? .authorized : .denied
    }
    
    func mapAdTrackingStatus() -> PermissionStatus {
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized: return .authorized
            case .denied: return .denied
            case .notDetermined: return .notDetermined
            case .restricted: return .disabled
            @unknown default: return .disabled
            }
        } else {
            return .disabled
        }
    }
}

extension iOSPermissionChecker: CLLocationManagerDelegate {
    // iOS 14 and later
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationCompletion?(mapLocationStatus())
        locationCompletion = nil
    }

    // For iOS versions prior to 14
    @available(iOS, introduced: 4.2, deprecated: 14.0)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationCompletion?(mapLocationStatus())
        locationCompletion = nil
    }
}

extension iOSPermissionChecker: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        bluetoothCompletion?(mapBluetoothStatus())
        bluetoothCompletion = nil
    }
}
