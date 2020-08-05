//
//  Pokedex.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct Pokedex: Decodable {
    let name: String
    let pokemonEntries: [PokemonEntry]
}

struct PokemonEntry: Decodable {
    let entryNumber: Int
    let name: String
    let url: String
    
    enum PokemonEntryCodingKeys: String, CodingKey {
        case entryNumber, pokemonSpecies
    }
    
    enum PokemonSpeciesCodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PokemonEntryCodingKeys.self)
        entryNumber = try container.decode(Int.self, forKey: .entryNumber)
        let pokemonSpecies = try container.nestedContainer(keyedBy: PokemonSpeciesCodingKeys.self, forKey: .pokemonSpecies)
        name = try pokemonSpecies.decode(String.self, forKey: .name)
        url = try pokemonSpecies.decode(String.self, forKey: .url)
    }
    
}
