//
//  Pokedex.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct Pokedex: Decodable {
    let names: [Name]
    let descriptions: [Description]
    let pokemonEntries: [PokemonEntry]
    
    private enum CodingKeys: String, CodingKey {
        case names
        case descriptions
        case pokemonEntries = "pokemon_entries"
    }
}

struct Name: Decodable {
    let name: String
}

struct Description: Decodable {
    let description: String
}

struct PokemonEntry: Decodable {
    let entryNumber: Int
    let pokemonSpecies: PokemonSpecies
    
    private enum CodingKeys: String, CodingKey {
        case entryNumber = "entry_number"
        case pokemonSpecies = "pokemon_species"
    }
}

struct PokemonSpecies: Decodable {
    let name: String
    let url: String
}
