//
//  GenerationData.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/9/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct GenerationData: Codable {
    let id: Int
    let mainRegion: String
    let name: String
    
    enum GenerationCodingKeys: String, CodingKey {
        case id, mainRegion, name
    }
    
    enum MainRegionCodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let generationContainer = try decoder.container(keyedBy: GenerationCodingKeys.self)
        
        id = try generationContainer.decode(Int.self, forKey: .id)
        name = try generationContainer.decode(String.self, forKey: .name)
        
        let regionContainer = try generationContainer.nestedContainer(keyedBy: MainRegionCodingKeys.self, forKey: .mainRegion)
        
        mainRegion = try regionContainer.decode(String.self, forKey: .name)
    }
}
