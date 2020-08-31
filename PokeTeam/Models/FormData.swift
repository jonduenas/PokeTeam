//
//  FormData.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct FormData: Codable {
    let id: Int
    let name: String
    let order: Int
    let formOrder: Int
    let isDefault: Bool
    let isMega: Bool
    let formName: String
    let pokemon: PokemonForm
}

struct PokemonForm: Codable {
    let name: String
    let url: String
}
