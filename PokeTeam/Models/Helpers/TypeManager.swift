//
//  TypeManager.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/21/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import CoreData
import Combine

public final class TypeManager {
    lazy var apiService = APIService()
    
    let allTypesURL = "https://pokeapi.co/api/v2/type/"
    
    private func fetchAllPokemonTypes() -> AnyPublisher<ResourceList, Error> {
        let url = URL(string: allTypesURL)!
        
        return apiService.fetch(type: ResourceList.self, from: url)
    }

    func fetchAllTypeData() -> AnyPublisher<[TypeData], Error> {
        let url = apiService.createURL(for: .types)
        
        return apiService.fetch(type: ResourceList.self, from: url!)
            .map(\.results)
            .flatMap { allTypes -> AnyPublisher<[TypeData], Error> in
                return allTypes.publisher
                    .flatMap { type in
                        self.apiService.fetch(type: TypeData.self, from: URL(string: type.url)!)
                    }
                    .collect()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func parseTypeDataToCoreData() {
        
    }
}
