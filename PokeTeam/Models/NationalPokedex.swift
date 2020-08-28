//
//  NationalPokedex.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/27/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct NationalPokedex: Codable {
    let count: Int
    let results: [Results]
}

struct Results: Codable {
    let name: String
    let url: String
}
