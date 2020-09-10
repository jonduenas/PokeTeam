//
//  PokemonTableCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/14/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class PokemonTableCell: UITableViewCell {

    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPokemonInfo(for pokemon: PokemonMO) {
        self.pokemonNameLabel.text = pokemon.name?.formatPokemonName()
        self.pokemonImageView.image = UIImage(named: String(pokemon.id))
    }

}
