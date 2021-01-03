//
//  APIService.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/20/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation
import Combine

final class APIService {
    
    func fetch<T: Decodable>(type: T.Type, from url: URL) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateHTTPStatus(200)
            .decode(type: type.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func createURL(for dataType: PokemonDataType, fromIndex index: Int? = nil) -> URL? {
        let baseStringURL = "https://pokeapi.co/api/v2/"
        
        switch dataType {
        case .allPokemon, .types:
            return URL(string: baseStringURL + dataType.rawValue)
        default:
            if let index = index {
                return URL(string: baseStringURL + dataType.rawValue + "\(index)")
            } else {
                return URL(string: baseStringURL + dataType.rawValue)
            }
        }
    }
    
    func fetchAll<T: Decodable>(type: T.Type, from url: URL) -> AnyPublisher<[T], Error> {
        return fetch(type: ResourceList.self, from: url)
            .map(\.results)
            .flatMap { results -> AnyPublisher<[T], Error> in
                return results.publisher
                    .flatMap { resource in
                        self.fetch(type: T.self, from: URL(string: resource.url)!)
                    }
                    .collect()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

}

enum PokemonDataType: String {
    case pokedex = "pokedex/"
    case pokemon = "pokemon/"
    case species = "pokemon-species/"
    case ability = "ability/"
    case move = "move/"
    case allPokemon = "pokemon-species?limit=5000"
    case form = "pokemon-form/"
    case types = "type/"
}
