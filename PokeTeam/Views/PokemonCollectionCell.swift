//
//  PokemonCollectionCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/14/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class PokemonCollectionCell: UICollectionViewCell {
    
    let cornerRadius: CGFloat = 47
    //let shadowLayer = CAShapeLayer()
    
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonType1Label: PokemonTypeLabel!
    @IBOutlet weak var pokemonType2Label: PokemonTypeLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        layer.cornerRadius = cornerRadius
        addShadow()
    }
    
    func setPokemonInfo(for pokemon: Pokemon) {
        pokemonNameLabel.text = pokemon.name.capitalized
        pokemonImageView.image = UIImage(named: pokemon.imageID)
        
        // Update Pokemon types
        if pokemon.type.count > 1 {
            pokemonType1Label.setType(for: pokemon.type[0])
            pokemonType2Label.setType(for: pokemon.type[1])
        } else {
            pokemonType1Label.setType(for: pokemon.type[0])
            pokemonType2Label.isHidden = true
        }
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
