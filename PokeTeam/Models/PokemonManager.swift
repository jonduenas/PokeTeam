//
//  Service.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine

enum PokemonDataType: String {
    case pokedex = "pokedex/"
    case pokemon = "pokemon/"
    case species = "pokemon-species/"
    case ability = "ability/"
    case move = "move/"
}

class PokemonManager {
    static let shared = PokemonManager()
    
    func combineFetchFromAPI<T: Decodable>(of type: T.Type, from url: URL) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateHTTPStatus(200)
            .decode(type: type.self, decoder: decoder)
            .eraseToAnyPublisher()
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
