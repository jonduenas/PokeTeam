//
//  GradientView.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/11/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class GradientView: UIView {
    lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [UIColor.white.cgColor, UIColor(red: 241 / 255, green: 232 / 255, blue: 240 / 255, alpha: 1).cgColor ]
        //gradient.colors = [UIColor.green.cgColor, UIColor.red.cgColor]
        //gradient.locations = [0.0, 1.0]
        //gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        //gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        return gradient
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.addSublayer(gradientLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.layer.addSublayer(gradientLayer)
    }
}
