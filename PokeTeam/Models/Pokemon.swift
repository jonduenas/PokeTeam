//
//  Pokemon.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation
import CoreData

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

public class Pokemon: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    let id: Int
    let name: String
    let height: Float
    let weight: Float
    let type: [PokemonType]
    let genus: String
    let generation: String
    let flavorText: String
    let stats: [PokemonStatName: Float]
    
    var imageID: String {
        return String(id)
    }
    
    var abilities: [PokemonAbility]
    var moves: [PokemonMove]?
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(height, forKey: "height")
        aCoder.encode(weight, forKey: "weight")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(genus, forKey: "genus")
        aCoder.encode(generation, forKey: "generation")
        aCoder.encode(flavorText, forKey: "flavorText")
        aCoder.encode(stats, forKey: "stats")
        aCoder.encode(abilities, forKey: "abilities")
        aCoder.encode(moves, forKey: "moves")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: "id") as? Int,
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let height = aDecoder.decodeObject(forKey: "height") as? Float,
            let weight = aDecoder.decodeObject(forKey: "weight") as? Float,
            let type = aDecoder.decodeObject(forKey: "type") as? [PokemonType],
            let genus = aDecoder.decodeObject(forKey: "genus") as? String,
            let generation = aDecoder.decodeObject(forKey: "generation") as? String,
            let flavorText = aDecoder.decodeObject(forKey: "flavorText") as? String,
            let stats = aDecoder.decodeObject(forKey: "stats") as? [PokemonStatName: Float],
            let abilities = aDecoder.decodeObject(forKey: "abilities") as? [PokemonAbility],
            let moves = aDecoder.decodeObject(forKey: "moves") as? [PokemonMove] else {
                return nil
        }
        
        self.id = id
        self.name = name
        self.height = height
        self.weight = weight
        self.type = type
        self.genus = genus
        self.generation = generation
        self.flavorText = flavorText
        self.stats = stats
        self.abilities = abilities
        self.moves = moves
    }
    
    init(id: Int, name: String, height: Float, weight: Float, type: [PokemonType], genus: String, generation: String, flavorText: String, stats: [PokemonStatName: Float], abilities: [PokemonAbility], moves: [PokemonMove]) {
        self.id = id
        self.name = name
        self.height = height
        self.weight = weight
        self.type = type
        self.genus = genus
        self.generation = generation
        self.flavorText = flavorText
        self.stats = stats
        self.abilities = abilities
        self.moves = moves
    }
    
    
}


