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
    
    func fetchFromAPI<T>(name: String? = nil, index: Int? = nil, urlString: String? = nil, dataType: PokemonDataType, decodeTo type: T.Type, completion: @escaping (T) -> Void) where T: Decodable {
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
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decodedData = try decoder.decode(type.self, from: data)
                completion(decodedData)
            } catch {
                print("Error: \(error)")
            }
        }
        task.resume()
    }
    
    func createURL(from name: String? = nil, index: Int? = nil, urlString: String? = nil, dataType: PokemonDataType) -> URL? {
        let baseStringURL = "https://pokeapi.co/api/v2/"
        
        if let name = name {
            let url = URL(string: baseStringURL + dataType.rawValue + name)
            return url
        }
        
        if let index = index {
            let url = URL(string: baseStringURL + dataType.rawValue + "\(index)")
            return url
        }
        
        if let urlString = urlString {
            let url = URL(string: urlString)
            return url
        }
        return nil
    }
    
//    func fetchPokemon(number: Int, from pokedex: Pokedex, completion: @escaping (Pokemon) -> Void) {
//        
//        guard let urlSpecies = URL(string: pokedex.pokemonEntries[number].url) else { return }
//        
//        let dispatchGroup = DispatchGroup()
//        
//        var pokemonData: PokemonData?
//        var speciesData: SpeciesData?
//        
//        // Fetch Pokemon Data
//        URLSession.shared.dataTask(with: urlPokemon) { (data, response, error) in
//            dispatchGroup.enter()
//            if error != nil {
//                print("Failed to fetch data with error: ", error!.localizedDescription)
//                return
//            }
//            
//            guard let data = data else { return }
//            
//            let decoder = JSONDecoder()
//            
//            do {
//                pokemonData = try decoder.decode(PokemonData.self, from: data)
//                dispatchGroup.leave()
//            } catch {
//                print(error)
//            }
//        }.resume()
//        
//        // Fetch Species Data
//        URLSession.shared.dataTask(with: urlSpecies) { (data, response, error) in
//            dispatchGroup.enter()
//            if error != nil {
//                print("Failed to fetch data with error: ", error!.localizedDescription)
//                return
//            }
//            
//            guard let data = data else { return }
//            
//            let decoder = JSONDecoder()
//            
//            do {
//                speciesData = try decoder.decode(SpeciesData.self, from: data)
//                dispatchGroup.leave()
//            } catch {
//                print(error)
//            }
//        }.resume()
//        
//        dispatchGroup.notify(queue: .main) {
//            guard let pokemonData = pokemonData else { return }
//            guard let speciesData = speciesData else { return }
//            
//            let pokemon = self.parsePokemonData(pokemonData: pokemonData, speciesData: speciesData)
//            
//            completion(pokemon)
//        }
//    }
    
//    func fetchData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            completion(data, response, error)
//        }.resume()
//    }
    
//    private func parsePokemonData(pokemonData: PokemonData, speciesData: SpeciesData) -> Pokemon {
//        let id = pokemonData.id
//        let name = pokemonData.name
//
//        var types = [String]()
//        for type in pokemonData.types {
//            types.insert(type.type.name, at: type.slot)
//        }
//
//        var stats = [String: Int]()
//        for stat in pokemonData.stats {
//            stats[stat.stat.name] = stat.baseStat
//        }
//
//        let generation = generations[speciesData.generation.name] ?? "Unknown"
//
//        let pokemon = Pokemon(id: id, name: name, type: types, region: generation, stats: stats, abilities: [])
//
//        return pokemon
//    }
//
//    func parseMoveData(pokemonData: PokemonData) -> [PokemonMove] {
//        var moves = [PokemonMove]()
//        for move in pokemonData.moves {
//            let moveName = move.move.name
//
//            let levelLearnedAt = move.versionGroupDetails.last?.levelLearnedAt
//            let moveLearnMethod = move.versionGroupDetails.last?.moveLearnMethod.name
//
//            let moveToAdd = PokemonMove(name: moveName, levelLearnedAt: levelLearnedAt, moveLearnMethod: moveLearnMethod!)
//
//            moves.append(moveToAdd)
//        }
//        return moves
//    }
    
//    func parseAbilityData(pokemonData: PokemonData) -> [PokemonAbility]? {
//        var abilities = [PokemonAbility]()
//        for ability in pokemonData.abilities {
//            var abilityData: AbilityData
//            let abilityName = ability.ability.name
//            var abilityDescription: String?
//            
//            guard let abilityURL = URL(string: ability.ability.url) else { return nil }
//            
//            let dispatchGroup = DispatchGroup()
//            
////            fetchData(from: abilityURL) { (data, response, error) in
////                dispatchGroup.enter()
////                if error != nil {
////                    print(error!.localizedDescription)
////                }
////                
////                guard let data = data else { return }
////                
////                let decoder = JSONDecoder()
////                
////                do {
////                    abilityData = try decoder.decode(AbilityData.self, from: data)
////                    dispatchGroup.leave()
////                } catch {
////                    print(error)
////                }
////            }
//            dispatchGroup.notify(queue: .main) {
//                abilityDescription = abilityData.flavorTextEntries.first?.flavorText
//                    
//                
//            }
//        }
//    }
}
