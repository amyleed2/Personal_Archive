//
//  Utils.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import UIKit

class Utils {

   static let _bundle_ = Bundle.main

   /**
    Information of this application.
    */
   class App {

       static var appName: String {
           return Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String ?? "" // FIXME: - default app name 기재
       }

       /**
        현재 설치된 앱 Version
        */
       static var version: String {
           guard let dictionary = _bundle_.infoDictionary,
               let version = dictionary["CFBundleShortVersionString"] as? String else {return "Unknown"}
           return version
       }

       /**
        현재 설치된 앱 build code
        */
       static var build: String? {
           guard let dictionary = _bundle_.infoDictionary,
               let build = dictionary["CFBundleVersion"] as? String else {return nil}
           return build
       }

       static var osVersion: String? {
           return UIDevice.current.systemVersion
       }

       static var bundleId: String? {
           return _bundle_.bundleIdentifier
       }
   }

    // 체크 : 탈옥여부
   static func isJailbroken() -> Bool {
       #if arch(i386) || arch(x86_64)
           // This is a Simulator not an idevice
           return false
       #endif

       let fileManager = FileManager.default
       if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
           fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
           fileManager.fileExists(atPath: "/bin/bash") ||
           fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
           fileManager.fileExists(atPath: "/etc/apt") ||
           fileManager.fileExists(atPath: "/usr/bin/ssh") ||
           fileManager.fileExists(atPath: "/private/var/lib/apt") {
           return true
       }

       if canOpen(path: "/Applications/Cydia.app") ||
           canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
           canOpen(path: "/bin/bash") ||
           canOpen(path: "/usr/sbin/sshd") ||
           canOpen(path: "/etc/apt") ||
           canOpen(path: "/usr/bin/ssh") {
           return true
       }

       let path = "/private/" + NSUUID().uuidString
       do {
           try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
           try fileManager.removeItem(atPath: path)
           return true
       } catch {
           return false
       }
   }

   static func canOpen(path: String) -> Bool {
       let file = fopen(path, "r")
       guard file != nil else { return false }
       fclose(file)
       return true
   }
}

