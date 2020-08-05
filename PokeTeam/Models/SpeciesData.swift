//
//  Species.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/3/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

// MARK: - Species
struct SpeciesData: Codable {
    let name: String
    let id: Int
    let flavorTextEntries: [FlavorText]
    let genera: [Genus]
    let generation: Generation
    
    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
        case name, id, genera, generation
    }
}

struct FlavorText: Codable {
    let flavorText: String
    
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
    }
}

struct Genus: Codable {
    let genus: String
}

struct Generation: Codable {
    let name: String
    let url: String
}
