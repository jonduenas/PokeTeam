//
//  Service.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine

enum DataError: Error {
    case invalidResponse
    case invalidData
    case decodingError
    case serverError
}

enum PokemonDataType: String {
    case pokedex = "pokedex/"
    case pokemon = "pokemon/"
    case species = "pokemon-species/"
    case ability = "ability/"
    case move = "move/"
}

class PokemonManager {
    static let shared = PokemonManager()
    
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    typealias result<T> = (Result<T, Error>) -> Void
    
    private var cancellable: AnyCancellable?
    
//    func fetchFromAPI<T: Decodable>(of type: T.Type, from url: URL) -> AnyPublisher<Response<T>, Error> {
//        return URLSession.shared.dataTaskPublisher(for: url)
//            .tryMap { result -> Response<T> in
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let value = try decoder.decode(T.self, from: result.data)
//                return Response(value: value, response: result.response)
//        }
//        .receive(on: DispatchQueue.main)
//        .eraseToAnyPublisher()
//    }
    
    func fetchFromAPI<T: Decodable>(of type: T.Type, from url: URL, completion: @escaping result<T>) {

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(DataError.invalidResponse))
                return
            }

            if 200 ... 299 ~= response.statusCode {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    do {
                        let decodedData: T = try decoder.decode(T.self, from: data)
                        completion(.success(decodedData))
                    } catch {
                        completion(.failure(DataError.decodingError))
                    }
                } else {
                    completion(.failure(DataError.serverError))
                }
            }
        }
        task.resume()
    }
    
    func createURL(for dataType: PokemonDataType, fromIndex index: Int) -> URL? {
        let baseStringURL = "https://pokeapi.co/api/v2/"
        
        return URL(string: baseStringURL + dataType.rawValue + "\(index)")
    }
    
    func parsePokemonData(pokemonData: PokemonData, speciesData: SpeciesData) -> Pokemon {
        let id = pokemonData.id
        let name = pokemonData.name
        let height = pokemonData.height / 10
        let weight = pokemonData.weight / 10

        // Type
        var typeArray = [PokemonType]()
        for type in pokemonData.types {
            typeArray.insert(PokemonType(rawValue: type.name) ?? .unknown, at: type.slot - 1)
        }
        
        // Genus
        var genus: String {
            for genus in speciesData.genera {
                if genus.language == "en" {
                    return genus.genus
                }
            }
            return "Unknown Genus"
        }
        
        // Generation
        let generation = speciesData.generation.name
        
        // Description
        var description: String {
            var englishFlavorTextArray = [String]()
            
            for entry in speciesData.flavorTextEntries {
                if entry.language == "en" {
                    englishFlavorTextArray.append(entry.flavorText)
                }
            }
            if let latestEntry = englishFlavorTextArray.last {
                return latestEntry.replacingOccurrences(of: "\n", with: " ")
            } else {
                return "Error loading description"
            }
        }
        
        // Stats
        var stats = [PokemonStatName: Float]()
        
        for stat in pokemonData.stats {
            if let statName = PokemonStatName(rawValue: stat.statName) {
                stats[statName] = Float(stat.baseStat)
            }
        }
        
        // Abilities
        var abilitiesArray = [PokemonAbility]()
        
        for ability in pokemonData.abilities {
            abilitiesArray.append(PokemonAbility(name: ability.name, isHidden: ability.isHidden, urlString: ability.url, description: nil))
        }
        
        // Moves
        var movesArray = [PokemonMove]()
        
        for move in pokemonData.moves {
            movesArray.append(PokemonMove(name: move.name, levelLearnedAt: move.levelLearnedAt, moveLearnMethod: move.moveLearnMethod, urlString: move.url, description: nil))
        }
        
        return Pokemon(id: id, name: name, height: height, weight: weight, type: typeArray, genus: genus, region: nil, generation: generation, description: description, stats: stats, abilities: abilitiesArray, moves: movesArray)
    }
    
    func addAbilityDescription(to ability: PokemonAbility, with abilityData: AbilityData) -> PokemonAbility {
        var englishFlavorTextArray = [String]()
        let description: String
        
        for flavorText in abilityData.flavorTextEntries {
            if flavorText.language == "en" {
                englishFlavorTextArray.append(flavorText.flavorText)
            }
        }
        
        if let latestFlavorText = englishFlavorTextArray.last {
            description = latestFlavorText.replacingOccurrences(of: "\n", with: " ")
        } else {
            description = "Error loading ability description"
        }
        
        var abilityToReturn = ability
        abilityToReturn.description = description
        
        return abilityToReturn
    }
}
