//
//  Pokemon.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct Pokemon: Decodable {
    let id: Int
    let name: String
    let type: [String]
    let region: String
    let urlString: String
    let spriteStringURL: String
}

