//
//  UILabel.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/27/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

extension UILabel {
    func addShadow(radius: CGFloat, offset: CGSize = CGSize(width: 0, height: 0.5), opacity: Float = 1) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.rasterizationScale = UIScreen.main.scale
    }
}
