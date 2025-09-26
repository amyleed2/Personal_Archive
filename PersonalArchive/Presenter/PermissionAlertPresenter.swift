//
//  PermissionAlertPresenter.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/26/25.
//

import Foundation
import UIKit

final class PermissionAlertPresenter {
    func showAlert(for type: PermissionType, in viewController: UIViewController) {
        let alert = UIAlertController(
            title: "\(type) Permission",
            message: "You must grant access to \(type) in order to use this feature",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
}
