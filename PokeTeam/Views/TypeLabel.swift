//
//  TypeLabel.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/8/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

//@IBDesignable
class PokemonTypeLabel: UILabel {
    @IBInspectable var cornerRadius: CGFloat = 5 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createLabel()
    }
    
    override func prepareForInterfaceBuilder() {
        createLabel()
    }
    
    private func createLabel() {
        refreshCorners(value: cornerRadius)
    }
    
    private func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
    
    func setType(for type: String) {
        self.text = type.capitalized
        self.backgroundColor = UIColor(named: type)
    }
}
