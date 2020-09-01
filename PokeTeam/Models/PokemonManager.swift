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
        // API uses ID# greater than 10000 to mark alt forms
        let altFormIDStart = 10000
        
        var pokemonMOArray = [PokemonMO]()
        
        for pokemon in pokedex.results {
            // Check if Pokemon already exists in Core Data
            let pokemonRequest: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
            pokemonRequest.predicate = NSPredicate(format: "name == %@", pokemon.name)
            
            if let pokemonFetched = try? context.fetch(pokemonRequest) {
                if pokemonFetched.count > 0 {
                    // Pokemon already exists in Core Data
                    if pokemonFetched[0].isAltForm {
                        // Skip alt forms showing in dex
                        continue
                    } else {
                        pokemonMOArray.append(pokemonFetched[0])
                        continue
                    }
                }
            }
            
            // No Pokemon with that name is found - create a new one
            let pokemonMO = PokemonMO(context: context)
            pokemonMO.name = pokemon.name
            pokemonMO.pokemonURL = pokemon.url
            
            // Pull ID out of URL string
            if let id = getID(from: pokemon.url) {
                pokemonMO.id = Int64(id)
                
                // Check if Pokemon is alt form
                if id > altFormIDStart {
                    pokemonMO.isAltForm = true
                    continue
                } else if id < 1 {
                    print("Error parsing Pokemon ID for \(pokemon.name). Got ID: \(id)")
                }
            }
            
            pokemonMOArray.append(pokemonMO)
        }
        
        return pokemonMOArray
    }
    
    private func getID(from url: String) -> Int? {
        let baseURL = "https://pokeapi.co/api/v2/pokemon/"
        if let returnInt = Int(url.dropFirst(baseURL.count).dropLast()) {
            return returnInt
        } else {
            print("Error getting ID from URL")
            return nil
        }
    }
    
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
        
        // Alt Forms
        if pokemonData.forms.count > 1 {
            pokemonToReturn.hasAltForm = true
        } else {
            pokemonToReturn.hasAltForm = false
        }

        return pokemonToReturn
    }
    
    func updateDetails(for pokemon: PokemonMO, with speciesData: SpeciesData) {
        // Genus
        pokemon.genus = parseGenus(with: speciesData)

        // Generation
        pokemon.generation = speciesData.generation.name

        // Description
        pokemon.flavorText = parseFlavorText(with: speciesData)
    }
    
    func updateDetails(for pokemon: PokemonMO, with pokemonData: PokemonData) {
        pokemon.imageID = String(pokemon.id)
        pokemon.height = pokemonData.height / 10
        pokemon.weight = pokemonData.weight / 10

        // Type
        pokemon.type = parseType(with: pokemonData)
        
        // Stats
        pokemon.stats = parseStats(with: pokemonData)

        // Abilities
        let abilities = parseAbilities(with: pokemonData)
        pokemon.abilities = NSSet(array: abilities)

        // Moves
        let moves = parseMoves(with: pokemonData)
        pokemon.moves = NSSet(array: moves)
    }
    
    func updateDetails(for pokemon: PokemonMO, with formData: [FormData]) {
        for form in formData {
            
        }
    }
    
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
    
    private func parseStats(with pokemonData: PokemonData) -> [String: Float] {
        var stats = [String: Float]()
        
        for stat in pokemonData.stats {
            stats[stat.statName] = Float(stat.baseStat)
        }
        return stats
    }
    
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
    
    func loadSavedPokemon() -> AnyPublisher<[PokemonMO], Never> {
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
        
        return Just(pokemonToReturn)
            .eraseToAnyPublisher()
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("MOC successfully saved.")
            } catch {
                print("Error saving context to Core Data: \(error)")
            }
        }
    }
}
