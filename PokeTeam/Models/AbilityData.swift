//
//  AbilityData.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/4/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct AbilityData: Codable {
    let flavorTextEntries: [AbilityFlavorTextEntry]
    let name: String
    let id: Int
}

struct AbilityFlavorTextEntry: Codable {
    let flavorText: String
    let language: String
    let versionGroup: String
    
    enum AbilityFlavorTextCodingKeys: String, CodingKey {
        case flavorText, language, versionGroup
    }
    
    enum AbilityFlavorTextLanguageCodingKeys: String, CodingKey {
        case name, url
    }
    
    enum AbilityFlavorTextVersionCodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let flavorTextContainer = try decoder.container(keyedBy: AbilityFlavorTextCodingKeys.self)
        
        flavorText = try flavorTextContainer.decode(String.self, forKey: .flavorText)
        
        let languageContainer = try flavorTextContainer.nestedContainer(keyedBy: AbilityFlavorTextLanguageCodingKeys.self, forKey: .language)
        
        language = try languageContainer.decode(String.self, forKey: .name)
        
        let versionContainer = try flavorTextContainer.nestedContainer(keyedBy: AbilityFlavorTextVersionCodingKeys.self, forKey: .versionGroup)
        
        versionGroup = try versionContainer.decode(String.self, forKey: .name)
    }
}
