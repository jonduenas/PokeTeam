//
//  CustomColor+UINavigationBar.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/10/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func setNavigationBarColor(to color: UIColor?, backgroundEffect: UIBlurEffect?) {
        // Customize Navigation Bar appearance
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = color
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        coloredAppearance.backgroundEffect = backgroundEffect
        
        let button = UIBarButtonItemAppearance(style: .plain)
        button.normal.titleTextAttributes = [.foregroundColor: UIColor.label]
        coloredAppearance.buttonAppearance = button
        
        let done = UIBarButtonItemAppearance(style: .done)
        done.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.doneButtonAppearance = done
        
        self.standardAppearance = coloredAppearance
        self.scrollEdgeAppearance = coloredAppearance
    }
}
