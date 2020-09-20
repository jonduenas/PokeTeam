//
//  MoveData.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/4/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct MoveData: Codable {
    let name: String
    let id: Int
    let power: Int?
    let pp: Int
    let type: String
    let damageClass: String
    let flavorTextEntries: [MoveFlavorTextEntry]
    
    enum MoveDataCodingKeys: String, CodingKey {
        case name, id, type, power, pp, damageClass, flavorTextEntries
    }
    
    enum MoveTypeCodingKeys: String, CodingKey {
        case name, url
    }
    
    enum MoveDamageClassCodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let moveContainer = try decoder.container(keyedBy: MoveDataCodingKeys.self)
        
        name = try moveContainer.decode(String.self, forKey: .name)
        id = try moveContainer.decode(Int.self, forKey: .id)
        power = try? moveContainer.decode(Int.self, forKey: .power)
        pp = try moveContainer.decode(Int.self, forKey: .pp)
        
        let typeContainer = try moveContainer.nestedContainer(keyedBy: MoveTypeCodingKeys.self, forKey: .type)
        
        type = try typeContainer.decode(String.self, forKey: .name)
        
        let damageClassContainer = try moveContainer.nestedContainer(keyedBy: MoveDamageClassCodingKeys.self, forKey: .damageClass)
        
        damageClass = try damageClassContainer.decode(String.self, forKey: .name)
        
        let flavorTextContainer = try decoder.container(keyedBy: MoveDataCodingKeys.self)
        
        flavorTextEntries = try flavorTextContainer.decode([MoveFlavorTextEntry].self, forKey: .flavorTextEntries)
    }
}

struct MoveFlavorTextEntry: Codable {
    let flavorText: String
    let language: String
    let versionGroup: String
    
    enum MoveFlavorTextCodingKeys: String, CodingKey {
        case flavorText, language, versionGroup
    }
    
    enum MoveFlavorTextLanguageCodingKeys: String, CodingKey {
        case name, url
    }
    
    enum MoveFlavorTextVersionCodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let flavorTextContainer = try decoder.container(keyedBy: MoveFlavorTextCodingKeys.self)
        
        flavorText = try flavorTextContainer.decode(String.self, forKey: .flavorText)
        
        let languageContainer = try flavorTextContainer.nestedContainer(keyedBy: MoveFlavorTextLanguageCodingKeys.self, forKey: .language)
        
        language = try languageContainer.decode(String.self, forKey: .name)
        
        let versionContainer = try flavorTextContainer.nestedContainer(keyedBy: MoveFlavorTextVersionCodingKeys.self, forKey: .versionGroup)
        
        versionGroup = try versionContainer.decode(String.self, forKey: .name)
    }
}
