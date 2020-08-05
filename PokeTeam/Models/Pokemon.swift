//
//  Pokemon.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct Pokemon {
    let id: Int
    let name: String
    let type: [String]
    let region: String
    //let spriteStringURL: String
    let stats: [String: Int]
    let abilities: [PokemonAbility]
}


