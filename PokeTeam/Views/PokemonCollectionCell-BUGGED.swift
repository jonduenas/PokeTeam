//
//  PokemonCollectionCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/14/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import CoreData

class PokemonCollectionCell: UICollectionViewCell {
    
    let cornerRadius: CGFloat = 47
    var pokemon: PokemonMO?
    
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
        //isUserInteractionEnabled = true
        layer.cornerRadius = cornerRadius
        addShadow()
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
//        tap.cancelsTouchesInView = false
//        addGestureRecognizer(tap)
    }
    
//    @objc func tapped() {
//        print("Tapped \(pokemon?.name)")
//        
//        print("Tapped")
//    }
    
    func setPokemonInfo(for pokemonObjectID: NSManagedObjectID) {
        guard let pokemon = PokemonManager.shared.context.object(with: pokemonObjectID) as? PokemonMO else { return }
        pokemonNameLabel.text = pokemon.name?.capitalized
        pokemonImageView.image = UIImage(named: pokemon.imageID!)
        
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
    
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
