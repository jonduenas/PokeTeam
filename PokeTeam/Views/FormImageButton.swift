//
//  FormImageButton.swift
//  PokeTeam
//
//  Created by Jon Duenas on 10/21/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class FormImageButton: UIButton {
    
    var backgroundImageName: String? {
        didSet {
            initializeBackgroundImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutButton()
    }
    
    func commonInit() {
        initializeBackgroundImage()
        
        if isSelected {
            backgroundColor = #colorLiteral(red: 0.9198423028, green: 0.9198423028, blue: 0.9198423028, alpha: 1)
        }
    }
    
    func initializeBackgroundImage() {
        if let background = backgroundImageName {
            guard let imageFile = UIImage(named: background) else { return }
            setImage(imageFile, for: .normal)
        }
    }
    
    func layoutButton() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        layer.cornerRadius = 10
    }
}
