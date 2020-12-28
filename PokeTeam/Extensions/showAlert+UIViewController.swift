//
//  showAlert+UIViewController.swift
//  PokeTeam
//
//  Created by Jon Duenas on 12/28/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String = "", message: String, afterConfirm: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let action = afterConfirm {
                action()
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
