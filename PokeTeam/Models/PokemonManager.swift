//
//  Service.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

enum PokemonDataType: String {
    case pokedex = "pokedex/"
    case pokemon = "pokemon/"
    case species = "pokemon-species/"
    case ability = "ability/"
    case move = "move/"
}

class PokemonManager {
    static let shared = PokemonManager()
    
    func fetchFromAPI<T>(name: String? = nil, index: Int? = nil, urlString: String? = nil, dataType: PokemonDataType? = nil, decodeTo type: T.Type, completion: @escaping (Data) -> Void) where T: Decodable {
        guard let url = createURL(from: name, index: index, urlString: urlString, dataType: dataType) else {
            fatalError("Failed to create valid URL")
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                fatalError("Failed to fetch data with error: \(error.localizedDescription)")
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                fatalError("Error: invalid HTTP response code")
            }
            guard let data = data else {
                fatalError("Error: missing response data")
            }
            completion(data)
        }
        task.resume()
    }
    
    func createURL(from name: String? = nil, index: Int? = nil, urlString: String? = nil, dataType: PokemonDataType? = nil) -> URL? {
        let baseStringURL = "https://pokeapi.co/api/v2/"
        
        if let name = name {
            if let dataType = dataType {
                let url = URL(string: baseStringURL + dataType.rawValue + name)
                return url
            }
        }
        
        if let index = index {
            if let dataType = dataType {
                let url = URL(string: baseStringURL + dataType.rawValue + "\(index)")
                return url
            }
        }
        
        if let urlString = urlString {
            let url = URL(string: urlString)
            return url
        }
        return nil
    }
    
//    func parseJSON<T: Decodable, U>(data: Data, to type: T.Type) -> U {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        do {
//            let decodedData = try decoder.decode(type.self, from: data)
//
//            switch type {
//            case type == PokemonData:
//                guard let dataToParse = decodedData as? PokemonData else { fatalError("Unable to parse PokemonData")}
//
//            }
//        } catch {
//            print("Error: \(error)")
//        }
//    }
    
    func parsePokedex(pokedexData: Data) -> Pokedex? {
        let pokedex: Pokedex
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            pokedex = try decoder.decode(Pokedex.self, from: pokedexData)
            return pokedex
        } catch {
            print("Error decoding Pokex: \(error)")
            return nil
        }
    }
    
    func parsePokemonData(pokemonData: Data, speciesData: Data) -> Pokemon {
        var decodedPokemon: PokemonData!
        var decodedSpecies: SpeciesData!
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // PokemonData
        do {
            decodedPokemon = try decoder.decode(PokemonData.self, from: pokemonData)
        } catch {
            print("Error decoding PokemonData: \(error)")
        }
        
        // SpeciesData
        do {
            decodedSpecies = try decoder.decode(SpeciesData.self, from: speciesData)
        } catch {
            print("Error decoding SpeciesData: \(error)")
        }
        
        let id = decodedPokemon.id
        let name = decodedPokemon.name
        let height = decodedPokemon.height / 10
        let weight = decodedPokemon.weight / 10

        // Type
        var typeArray = [PokemonType]()
        for type in decodedPokemon.types {
            typeArray.insert(PokemonType(rawValue: type.name) ?? .unknown, at: type.slot - 1)
        }
        
        // Genus
        var genus: String {
            for genus in decodedSpecies.genera {
                if genus.language == "en" {
                    return genus.genus
                }
            }
            return "Unknown Genus"
        }
        
        // Generation
        let generation = decodedSpecies.generation.name
        
        // Description
        var description: String {
            var englishFlavorTextArray = [String]()
            
            for entry in decodedSpecies.flavorTextEntries {
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
        
        for stat in decodedPokemon.stats {
            if let statName = PokemonStatName(rawValue: stat.statName) {
                stats[statName] = Float(stat.baseStat)
            }
        }
        
        // Abilities
        var abilitiesArray = [PokemonAbility]()
        
        for ability in decodedPokemon.abilities {
            abilitiesArray.append(PokemonAbility(name: ability.name, isHidden: ability.isHidden, urlString: ability.url, description: nil))
        }
        
        // Moves
        var movesArray = [PokemonMove]()
        
        for move in decodedPokemon.moves {
            movesArray.append(PokemonMove(name: move.name, levelLearnedAt: move.levelLearnedAt, moveLearnMethod: move.moveLearnMethod, urlString: move.url, description: nil))
        }
        
        return Pokemon(id: id, name: name, height: height, weight: weight, type: typeArray, genus: genus, region: nil, generation: generation, description: description, stats: stats, abilities: abilitiesArray, moves: movesArray)
    }
    
    func parseAbilityData(data: Data, ability: PokemonAbility) -> PokemonAbility? {
        var decodedAbility: AbilityData!
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            decodedAbility = try decoder.decode(AbilityData.self, from: data)
        } catch {
            print("Error decoding PokemonAbility: \(error)")
        }
        
        var englishFlavorTextArray = [String]()
        let description: String
        
        for flavorText in decodedAbility.flavorTextEntries {
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
