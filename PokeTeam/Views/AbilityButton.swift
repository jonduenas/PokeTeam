//
//  AbilityButton.swift
//  PokeTeam
//
//  Created by Jon Duenas on 10/19/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class AbilityButton: UIButton {

    let backgroundColorString = "poke-blue"
    let cornerRadius: CGFloat = 20
    let textColor = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        widthAnchor.constraint(equalToConstant: 175).isActive = true
        backgroundColor = UIColor(named: backgroundColorString)
        titleLabel?.textColor = textColor
        layer.cornerRadius = cornerRadius
        clipsToBounds = false
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
        layer.shadowRadius = 2
    }
}
