//
//  Pokemon.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

enum PokemonType: String {
    case normal, fire, water, electric, grass, ice, fighting, poison, ground, flying, psychic, bug, rock, ghost, dragon, dark, steel, fairy, unknown
}

enum PokemonStatName: String {
    case hp, attack, defense, speed
    case specialAttack = "special-attack"
    case specialDefense = "special-defense"
}

enum PokemonStatShortName: String {
    case hp = "HP"
    case attack = "ATK"
    case defense = "DEF"
    case specialAttack = "SPA"
    case specialDefense = "SPD"
    case speed = "SPE"
}

struct Pokemon {
    let id: Int
    let name: String
    let height: Float
    let weight: Float
    let type: [PokemonType]
    let genus: String
    let region: String?
    let generation: String
    let description: String
    let stats: [PokemonStatName: Float]
    
    var imageID: String {
        return String(id)
    }
    
    var abilities: [PokemonAbility]?
    var moves: [PokemonMove]?
}


