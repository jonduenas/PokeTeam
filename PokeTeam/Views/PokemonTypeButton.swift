//
//  PokemonTypeButton.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/20/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class PokemonTypeButton: UIButton {
    private let cornerRadius: CGFloat = 10
    
    var pokemonType: PokemonType = .none {
        didSet {
            setBackgroundAndTitle()
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
    
    private func commonInit() {
        setBackgroundAndTitle()
        layer.cornerRadius = cornerRadius
    }
    
    private func setBackgroundAndTitle() {
        backgroundColor = UIColor(named: pokemonType.rawValue)
        setTitle(pokemonType.rawValue.capitalized, for: .normal)
    }
}
