//
//  PokemonCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/14/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class PokemonCell: UITableViewCell {

    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
