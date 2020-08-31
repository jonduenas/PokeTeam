//
//  Service.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine
import CoreData

enum PokemonDataType: String {
    case pokedex = "pokedex/"
    case pokemon = "pokemon/"
    case species = "pokemon-species/"
    case ability = "ability/"
    case move = "move/"
    case allPokemon = "pokemon?limit=5000"
    case form = "pokemon-form/"
}

class PokemonManager {
    static let shared = PokemonManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: Networking methods
    
    func fetchFromAPI<T: Decodable>(of type: T.Type, from url: URL) -> AnyPublisher<T, Error> {
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
        case .allPokemon:
            return URL (string: baseStringURL + dataType.rawValue)
        default:
            guard let index = index else { return nil }
            return URL(string: baseStringURL + dataType.rawValue + "\(index)")
        }
    }
    
    // MARK: Core Data parsing methods
  
    func parseNationalPokedex(pokedex: NationalPokedex) -> [PokemonMO] {
        var pokemonMOArray = [PokemonMO]()
        
        for pokemon in pokedex.results {
            // Check if Pokemon already exists in Core Data
            let pokemonRequest: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
            pokemonRequest.predicate = NSPredicate(format: "name == %@", pokemon.name)
            
            if let pokemonFetched = try? context.fetch(pokemonRequest) {
                if pokemonFetched.count > 0 {
                    // Pokemon already exists in Core Data
                    pokemonMOArray.append(pokemonFetched[0])
                    continue
                }
            }
            
            // No Pokemon with that name is found - create a new one
            let pokemonMO = PokemonMO(context: context)
            pokemonMO.name = pokemon.name
            pokemonMO.pokemonURL = pokemon.url
            
            // Pull ID out of URL string
            pokemonMO.id = Int64(getID(from: pokemon.url) ?? 0)
            
            pokemonMOArray.append(pokemonMO)
        }        
        return pokemonMOArray
    }
    
    private func getID(from url: String) -> Int? {
        let baseURL = "https://pokeapi.co/api/v2/pokemon/"
        return Int(url.dropFirst(baseURL.count).dropLast())
    }
    
//    func parsePokemonData(pokemonData: PokemonData) -> PokemonMO {
//        let pokemon = PokemonMO(context: context)
//
//        pokemon.id = Int64(pokemonData.id)
//        pokemon.name = pokemonData.name
//        pokemon.height = pokemonData.height / 10
//        pokemon.weight = pokemonData.weight / 10
//
//        // Type
//        pokemon.type = parseType(with: pokemonData)
//
//        // Stats
//        pokemon.stats = parseStats(with: pokemonData)
//
//        // Abilities
//        let abilities = parseAbilities(with: pokemonData)
//        for ability in abilities {
//            pokemon.addToAbilities(ability)
//        }
//
//        // Moves
//        let moves = parseMoves(with: pokemonData)
//        for move in moves {
//            pokemon.addToMoves(move)
//        }
//
//        return pokemon
//    }
    
    func parsePokemonData(pokemonData: PokemonData, speciesData: SpeciesData) -> PokemonMO {
        let pokemonToReturn = PokemonMO(context: context)

        pokemonToReturn.id = Int64(pokemonData.id)
        pokemonToReturn.name = pokemonData.name
        pokemonToReturn.height = pokemonData.height / 10
        pokemonToReturn.weight = pokemonData.weight / 10

        // Type
        pokemonToReturn.type = parseType(with: pokemonData)

        // Genus
        pokemonToReturn.genus = parseGenus(with: speciesData)

        // Generation
        pokemonToReturn.generation = speciesData.generation.name

        // Description
        pokemonToReturn.flavorText = parseFlavorText(with: speciesData)

        // Stats
        pokemonToReturn.stats = parseStats(with: pokemonData)

        // Abilities
        let abilities = parseAbilities(with: pokemonData)
        for ability in abilities {
            pokemonToReturn.addToAbilities(ability)
        }

        // Moves
        let moves = parseMoves(with: pokemonData)
        for move in moves {
            pokemonToReturn.addToMoves(move)
        }

        return pokemonToReturn
    }
    
    func updateDetails(for pokemon: PokemonMO, with pokemonData: PokemonData, and speciesData: SpeciesData) {
        pokemon.imageID = String(pokemon.id)
        pokemon.height = pokemonData.height / 10
        pokemon.weight = pokemonData.weight / 10

        // Type
        pokemon.type = parseType(with: pokemonData)

        // Genus
        pokemon.genus = parseGenus(with: speciesData)

        // Generation
        pokemon.generation = speciesData.generation.name

        // Description
        pokemon.flavorText = parseFlavorText(with: speciesData)

        // Stats
        pokemon.stats = parseStats(with: pokemonData)

        // Abilities
        let abilities = parseAbilities(with: pokemonData)
        pokemon.abilities = NSSet(array: abilities)

        // Moves
        let moves = parseMoves(with: pokemonData)
        pokemon.moves = NSSet(array: moves)
    }
//    func parsePokemonData(pokemonData: PokemonData, speciesData: SpeciesData) -> Pokemon {
//        let id = pokemonData.id
//        let name = pokemonData.name
//        let height = pokemonData.height / 10
//        let weight = pokemonData.weight / 10
//
//        // Type
//        let typeArray = parseType(with: pokemonData)
//
//        // Genus
//        let genus = parseGenus(with: speciesData)
//
//        // Generation
//        let generation = speciesData.generation.name
//
//        // Description
//        let flavorText = parseFlavorText(with: speciesData)
//
//        // Stats
//        let stats = parseStats(with: pokemonData)
//
//        // Abilities
//        let abilitiesArray = parseAbilities(with: pokemonData)
//
//        // Moves
//        let movesArray = parseMoves(with: pokemonData)
//
//        return Pokemon(id: id, name: name, height: height, weight: weight, type: typeArray, genus: genus, generation: generation, flavorText: flavorText, stats: stats, abilities: abilitiesArray, moves: movesArray)
//    }
    
//    func addAbilityDescription(to ability: PokemonAbility, with abilityData: AbilityData) -> PokemonAbility {
//        var englishFlavorTextArray = [String]()
//        let description: String
//
//        for flavorText in abilityData.flavorTextEntries {
//            if flavorText.language == "en" {
//                englishFlavorTextArray.append(flavorText.flavorText)
//            }
//        }
//
//        if let latestFlavorText = englishFlavorTextArray.last {
//            description = latestFlavorText.replacingOccurrences(of: "\n", with: " ")
//        } else {
//            description = "Error loading ability description"
//        }
//
//        let abilityToReturn = ability
//        abilityToReturn.abilityDescription = description
//
//        return abilityToReturn
//    }
    
    func addAbilityDescription(to ability: AbilityMO, with abilityData: AbilityData) {
        var englishFlavorTextArray = [String]()
        let flavorText: String
        
        for flavorText in abilityData.flavorTextEntries {
            if flavorText.language == "en" {
                englishFlavorTextArray.append(flavorText.flavorText)
            }
        }
        
        if let latestEntry = englishFlavorTextArray.last {
            flavorText = latestEntry.replacingOccurrences(of: "\n", with: " ")
        } else {
            flavorText = ""
        }
        
        ability.abilityDescription = flavorText
        ability.id = Int64(abilityData.id)
    }
    
    // MARK: Private parsing methods
    
//    private func parseType(with pokemonData: PokemonData) -> [PokemonType] {
//        var typeArray = [PokemonType]()
//        for type in pokemonData.types {
//            typeArray.insert(PokemonType(rawValue: type.name) ?? .unknown, at: type.slot - 1)
//        }
//        return typeArray
//    }
    
    private func parseType(with pokemonData: PokemonData) -> [String] {
        var typeArray = [String]()
        for type in pokemonData.types {
            typeArray.insert(type.name, at: type.slot - 1)
        }
        return typeArray
    }
    
    private func parseGenus(with speciesData: SpeciesData) -> String {
        for genus in speciesData.genera {
            if genus.language == "en" {
                return genus.genus
            }
        }
        return "Unknown Genus"
    }
    
    private func parseFlavorText(with speciesData: SpeciesData) -> String {
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
    
//    private func parseStats(with pokemonData: PokemonData) -> [PokemonStatName: Float] {
//        var stats = [PokemonStatName: Float]()
//
//        for stat in pokemonData.stats {
//            if let statName = PokemonStatName(rawValue: stat.statName) {
//                stats[statName] = Float(stat.baseStat)
//            }
//        }
//
//        return stats
//    }
    
    private func parseStats(with pokemonData: PokemonData) -> [String: Float] {
        var stats = [String: Float]()
        
        for stat in pokemonData.stats {
            stats[stat.statName] = Float(stat.baseStat)
        }
        return stats
    }
    
//    private func parseAbilities(with pokemonData: PokemonData) -> [PokemonAbility] {
//        var abilitiesArray = [PokemonAbility]()
//
//        for ability in pokemonData.abilities {
//            abilitiesArray.append(PokemonAbility(name: ability.name, isHidden: ability.isHidden, urlString: ability.url, abilityDescription: nil))
//        }
//
//        return abilitiesArray
//    }
    
    private func parseAbilities(with pokemonData: PokemonData) -> Array<AbilityMO> {
        var abilitiesArray = [AbilityMO]()
        
        for ability in pokemonData.abilities {
            let abilityMO = AbilityMO(context: context)
            abilityMO.name = ability.name
            abilityMO.isHidden = ability.isHidden
            abilityMO.urlString = ability.url
            
            abilitiesArray.append(abilityMO)
        }
        
        return abilitiesArray
    }
    
//    private func parseMoves(with pokemonData: PokemonData) -> [PokemonMove] {
//        var movesArray = [PokemonMove]()
//
//        for move in pokemonData.moves {
//            movesArray.append(PokemonMove(name: move.name, levelLearnedAt: move.levelLearnedAt, moveLearnMethod: move.moveLearnMethod, urlString: move.url, moveDescription: nil))
//        }
//
//        return movesArray
//    }
    
    private func parseMoves(with pokemonData: PokemonData) -> [MoveMO] {
        var movesArray = [MoveMO]()
        
        for move in pokemonData.moves {
            let moveMO = MoveMO(context: context)
            moveMO.name = move.name
            moveMO.levelLearnedAt = Int64(move.levelLearnedAt)
            moveMO.moveLearnMethod = move.moveLearnMethod
            moveMO.urlString = move.url
            
            movesArray.append(moveMO)
        }
        
        return movesArray
    }
    
    // MARK: - Core Data Methods
    
    func loadSavedPokemon() -> [PokemonMO] {
        let request: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
        
        var pokemonToReturn = [PokemonMO]()
        
        do {
            pokemonToReturn = try self.context.fetch(request)
            print("Successfully fetched \(pokemonToReturn.count) pokemon from Core Data")
        } catch {
            print("Fetch from Core Data failed: \(error)")
        }
        
        return pokemonToReturn
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context to Core Data: \(error)")
            }
        }
    }
}

extension String {
    init(withInt int: Int, leadingZeros: Int = 1) {
        self.init(format: "%0\(leadingZeros)d", int)
    }

    func leadingZeros(_ zeros: Int) -> String {
        if let int = Int(self) {
            return String(withInt: int, leadingZeros: zeros)
        }
        print("Warning: \(self) is not an Int")
        return ""
    }
    
    func formatAbilityName() -> String {
        if self == "soul-heart" {
            return self.capitalized
        } else {
            return self.capitalized.replacingOccurrences(of: "-", with: " ")
        }
    }
}
