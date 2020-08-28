//
//  PokemonAbility.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/4/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

public class PokemonAbility: NSObject {
    
    let name: String
    let isHidden: Bool
    let urlString: String
    var abilityDescription: String?
    
    init(name: String, isHidden: Bool, urlString: String, abilityDescription: String?) {
        self.name = name
        self.isHidden = isHidden
        self.urlString = urlString
        self.abilityDescription = abilityDescription
    }
}
