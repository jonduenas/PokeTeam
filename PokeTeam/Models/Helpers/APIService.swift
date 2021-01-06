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
        let baseURL = URL("https://pokeapi.co/api/v2/")
        
        var returnURL = URL(string: dataType.rawValue, relativeTo: baseURL)
        
        if let indexNumber = index {
            // If index is set and not nil, add index to end of URL
            returnURL?.appendPathComponent(String(indexNumber))
        }
        
        return returnURL
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
    case pokedex = "pokedex"
    case pokemon = "pokemon"
    case species = "pokemon-species"
    case ability = "ability"
    case move = "move"
    case allPokemon = "pokemon-species?limit=5000"
    case form = "pokemon-form"
    case types = "type"
}
