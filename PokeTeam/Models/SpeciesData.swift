//
//  Species.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/3/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

// Generic Struct for reused structure from API
struct NameAndURL: Codable {
    let name: String
    let url: String
}

// MARK: - Species
struct SpeciesData: Codable {
    let name: String
    let id: Int
    let flavorTextEntries: [FlavorTextEntry]
    let genera: [Genus]
    let generation: NameAndURL
    let isBaby: Bool
    let isLegendary: Bool
    let isMythical: Bool
    let order: Int?
    let pokedexNumbers: [PokedexNumber]
    let varieties: [Variety]
}

struct FlavorTextEntry: Codable {
    let flavorText: String
    let language: String
    let version: String
    
    enum FlavorTextCodingKeys: String, CodingKey {
        case flavorText, language, version
    }
    
    enum FlavorTextLanguageCodingKeys: String, CodingKey {
        case name, url
    }
    
    enum FlavorTextVersionCodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let flavorTextContainer = try decoder.container(keyedBy: FlavorTextCodingKeys.self)
        
        flavorText = try flavorTextContainer.decode(String.self, forKey: .flavorText)
        
        let languageContainer = try flavorTextContainer.nestedContainer(keyedBy: FlavorTextLanguageCodingKeys.self, forKey: .language)
        
        language = try languageContainer.decode(String.self, forKey: .name)
        
        let versionContainer = try flavorTextContainer.nestedContainer(keyedBy: FlavorTextVersionCodingKeys.self, forKey: .version)
        
        version = try versionContainer.decode(String.self, forKey: .name)
    }
}

struct Genus: Codable {
    let genus: String
    let language: String
    
    enum GenusCodingKeys: String, CodingKey {
        case genus, language
    }
    
    enum GenusLanguageCodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let genusContainer = try decoder.container(keyedBy: GenusCodingKeys.self)
        genus = try genusContainer.decode(String.self, forKey: .genus)
        
        let languageContainer = try genusContainer.nestedContainer(keyedBy: GenusLanguageCodingKeys.self, forKey: .language)
        language = try languageContainer.decode(String.self, forKey: .name)
    }
}

struct PokedexNumber: Codable {
    let entryNumber: Int
    let pokedex: NameAndURL
}

struct Variety: Codable {
    let isDefault: Bool
    let pokemon: NameAndURL
}
