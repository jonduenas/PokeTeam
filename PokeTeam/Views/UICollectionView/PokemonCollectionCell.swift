//
//  PokemonCollectionCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/8/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class PokemonCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "PokemonCollectionCell"
    
    let cornerRadius: CGFloat = 45
    
    var pokemon: PokemonMO? {
        didSet {
            setPokemonInfo()
        }
    }
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonType1Label: PokemonTypeLabel!
    @IBOutlet weak var pokemonType2Label: PokemonTypeLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.white
        layer.cornerRadius = cornerRadius
        addShadow()
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
    func setPokemonInfo() {
        guard let pokemon = pokemon else { return }
        
        pokemonNameLabel.text = pokemon.name?.formatPokemonName()
        
        if let imageID = pokemon.imageID {
            pokemonImageView.image = UIImage(named: imageID)
        } else {
            pokemonImageView.image = UIImage(named: "substitute")
        }
        
        // Update Pokemon types
        if let pokemonTypes = pokemon.type {
            if pokemonTypes.count > 1 {
                pokemonType1Label.setType(for: pokemonTypes[0])
                pokemonType2Label.setType(for: pokemonTypes[1])
                pokemonType2Label.isHidden = false
            } else {
                pokemonType1Label.setType(for: pokemonTypes[0])
                pokemonType2Label.isHidden = true
            }
        }
    }
}
