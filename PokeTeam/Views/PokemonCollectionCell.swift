//
//  PokemonCollectionCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/14/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class PokemonCollectionCell: UICollectionViewCell {
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 15
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.cornerRadius = 15
    }
}
