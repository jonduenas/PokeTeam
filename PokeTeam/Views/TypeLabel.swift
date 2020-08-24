//
//  TypeLabel.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/8/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

@IBDesignable
class PokemonTypeLabel: UILabel {
    let colorDictionary: [PokemonType: UIColor] = [
        .normal : #colorLiteral(red: 0.6604253054, green: 0.6575222611, blue: 0.4722985029, alpha: 1),
        .fire: #colorLiteral(red: 0.9430522323, green: 0.500674963, blue: 0.18630445, alpha: 1),
        .water: #colorLiteral(red: 0.4103244543, green: 0.5630832911, blue: 0.9429332614, alpha: 1),
        .electric: #colorLiteral(red: 0.9735011458, green: 0.8164314032, blue: 0.1857287586, alpha: 1),
        .grass: #colorLiteral(red: 0.4723884463, green: 0.7830661535, blue: 0.3122061789, alpha: 1),
        .ice: #colorLiteral(red: 0.5975236893, green: 0.8461193442, blue: 0.84528476, alpha: 1),
        .fighting: #colorLiteral(red: 0.7551248074, green: 0.1901937127, blue: 0.1567256749, alpha: 1),
        .poison: #colorLiteral(red: 0.6268454194, green: 0.2496165633, blue: 0.626177609, alpha: 1),
        .ground: #colorLiteral(red: 0.8783461452, green: 0.7512584329, blue: 0.4078472555, alpha: 1),
        .flying: #colorLiteral(red: 0.6595369577, green: 0.5635969043, blue: 0.94169873, alpha: 1),
        .psychic: #colorLiteral(red: 0.9737138152, green: 0.343855083, blue: 0.5335571766, alpha: 1),
        .bug: #colorLiteral(red: 0.6570427418, green: 0.7231122851, blue: 0.1252906322, alpha: 1),
        .rock: #colorLiteral(red: 0.7233955264, green: 0.6271670461, blue: 0.2228657305, alpha: 1),
        .ghost: #colorLiteral(red: 0.4378493428, green: 0.3458217978, blue: 0.5958074331, alpha: 1),
        .dragon: #colorLiteral(red: 0.4412069917, green: 0.2183938026, blue: 0.9708285928, alpha: 1),
        .dark: #colorLiteral(red: 0.4411335588, green: 0.3436093628, blue: 0.2820082605, alpha: 1),
        .steel: #colorLiteral(red: 0.7238504291, green: 0.7228143215, blue: 0.8153695464, alpha: 1),
        .fairy: #colorLiteral(red: 0.9356001616, green: 0.5982843041, blue: 0.6742190719, alpha: 1),
        .unknown: UIColor.black
    ]
    
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
    
    func setType(for type: PokemonType) {
        self.text = type.rawValue.capitalized
        self.backgroundColor = colorDictionary[type]
    }
}
