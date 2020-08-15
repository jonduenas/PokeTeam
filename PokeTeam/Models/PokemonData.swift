//
//  PokemonData.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/3/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct PokemonData: Codable {
    let abilities: [Ability]
    let id: Int
    let moves: [Move]
    let name: String
    let stats: [Stat]
    let types: [Type]
    let height: Float
    let weight: Float
}

// MARK: Abilities

struct Ability: Codable {
    let isHidden: Bool
    let slot: Int
    let name: String
    let url: String
    
    enum AbilityCodingKeys: String, CodingKey {
        case isHidden, slot, ability
    }
    
    enum AbilityNameCodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AbilityCodingKeys.self)
        
        isHidden = try container.decode(Bool.self, forKey: .isHidden)
        slot = try container.decode(Int.self, forKey: .slot)
        
        let ability = try container.nestedContainer(keyedBy: AbilityNameCodingKeys.self, forKey: .ability)
        
        name = try ability.decode(String.self, forKey: .name)
        url = try ability.decode(String.self, forKey: .url)
    }
}

// MARK: Moves

struct Move: Codable {
    let name: String
    let url: String
    let levelLearnedAt: Int
    let moveLearnMethod: String
    
    enum MoveCodingKeys: String, CodingKey {
        case move, versionGroupDetails
    }
    
    enum MoveNameCodingKeys: String, CodingKey {
        case name, url
    }
    
    enum VersionGroupKeys: String, CodingKey {
        case levelLearnedAt, moveLearnMethod
    }
    
    enum MoveLearnMethodCodingKeys: String, CodingKey {
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MoveCodingKeys.self)
        
        let moveContainer = try container.nestedContainer(keyedBy: MoveNameCodingKeys.self, forKey: .move)
        name = try moveContainer.decode(String.self, forKey: .name)
        url = try moveContainer.decode(String.self, forKey: .url)
        
        var versionGroupUnkeyedContainer = try container.nestedUnkeyedContainer(forKey: .versionGroupDetails)
        var levelLearnedArray = [Int]()
        var moveLearnMethodArray = [String]()
        while !versionGroupUnkeyedContainer.isAtEnd {
            let versionGroupContainer = try versionGroupUnkeyedContainer.nestedContainer(keyedBy: VersionGroupKeys.self)
            levelLearnedArray.append(try versionGroupContainer.decode(Int.self, forKey: .levelLearnedAt))
            
            let moveLearnedContainer = try versionGroupContainer.nestedContainer(keyedBy: MoveLearnMethodCodingKeys.self, forKey: .moveLearnMethod)
            moveLearnMethodArray.append(try moveLearnedContainer.decode(String.self, forKey: .name))
        }
        levelLearnedAt = levelLearnedArray[0]
        moveLearnMethod = moveLearnMethodArray[0]
    }
}

// MARK: Stats

struct Stat: Codable {
    let baseStat: Int
    let statName: String
    
    enum StatCodingKeys: String, CodingKey {
        case stat, baseStat
    }
    
    enum StatDetailCodingKeys: String, CodingKey {
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StatCodingKeys.self)
        
        baseStat = try container.decode(Int.self, forKey: .baseStat)
                
        let stat = try container.nestedContainer(keyedBy: StatDetailCodingKeys.self, forKey: .stat)
        
        statName = try stat.decode(String.self, forKey: .name)
    }
}

// MARK: Types

struct Type: Codable {
    let slot: Int
    let name: String
    let url: String
    
    enum TypeCodingKeys: String, CodingKey {
        case slot, type
    }
    
    enum TypeDetailCodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypeCodingKeys.self)
        
        slot = try container.decode(Int.self, forKey: .slot)
        
        let type = try container.nestedContainer(keyedBy: TypeDetailCodingKeys.self, forKey: .type)
        
        name = try type.decode(String.self, forKey: .name)
        url = try type.decode(String.self, forKey: .url)
    }
}
