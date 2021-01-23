//
//  CustomTabController.swift
//  PokeTeam
//
//  Created by Jon Duenas on 1/22/21.
//  Copyright © 2021 Jon Duenas. All rights reserved.
//

import UIKit

class CustomTabController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
        tabBar.barStyle = .black
        tabBar.isTranslucent = true
        tabBar.barTintColor = .black
        tabBar.tintColor = .white
    }
}
