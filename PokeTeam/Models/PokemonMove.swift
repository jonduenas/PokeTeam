//
//  PokemonMove.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/4/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

public class PokemonMove: NSObject {
    let name: String
    let levelLearnedAt: Int?
    let moveLearnMethod: String
    let urlString: String
    let moveDescription: String?
    
    init(name: String, levelLearnedAt: Int? = nil, moveLearnMethod: String, urlString: String, moveDescription: String? = nil) {
        self.name = name
        self.levelLearnedAt = levelLearnedAt
        self.moveLearnMethod = moveLearnMethod
        self.urlString = urlString
        self.moveDescription = moveDescription
    }
}
