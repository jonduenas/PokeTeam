//
//  PokemonManager.swift
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
    case allPokemon = "pokemon-species?limit=5000"
    case form = "pokemon-form/"
}

class PokemonManager {
    static let shared = PokemonManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let backgroundContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
    
    init() {
        backgroundContext.mergePolicy = context.mergePolicy
    }
    
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
  
    func updateNationalPokedex(pokedex: NationalPokedex) {
        for pokemon in pokedex.results {
            // Check if Pokemon already exists in Core Data
            let isFound = checkCDForMatch(with: pokemon)
            
            if isFound {
                // Pokemon with matching name is found
                continue
            } else {
                // No Pokemon with that name is found - create a new one
                let pokemonMO = PokemonMO(context: backgroundContext)
                pokemonMO.managedObjectContext?.performAndWait {
                    pokemonMO.name = pokemon.name
                    pokemonMO.speciesURL = pokemon.url
                    
                    // Pull ID out of URL string
                    if let id = getID(from: pokemon.url) {
                        pokemonMO.id = Int64(id)
                    }
                }
            }
        }
        
        saveContext(backgroundContext)
    }
    
    private func checkCDForMatch(with pokemon: NameAndURL) -> Bool {
        var isFound: Bool = false
        
        let pokemonRequest: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
        pokemonRequest.predicate = NSPredicate(format: "name == %@", pokemon.name)
        
        if let pokemonFetched = try? backgroundContext.fetch(pokemonRequest) {
            if pokemonFetched.count > 0 {
                // Pokemon already exists in Core Data
                isFound = true
            }
        }
        
        return isFound
    }
    
    private func getID(from url: String) -> Int? {
        let baseURL = "https://pokeapi.co/api/v2/pokemon-species/"
        if let returnInt = Int(url.dropFirst(baseURL.count).dropLast()) {
            return returnInt
        } else {
            print("Error getting ID from URL")
            return nil
        }
    }
    
    func convertToMO(in context: NSManagedObjectContext, with objectID: NSManagedObjectID) -> NSManagedObject {
        return context.object(with: objectID)
    }
    
//    func parsePokemonData(pokemonData: PokemonData, speciesData: SpeciesData) -> PokemonMO {
//        let pokemonToReturn = PokemonMO(context: context)
//
//        pokemonToReturn.id = Int64(pokemonData.id)
//        pokemonToReturn.name = pokemonData.name
//        pokemonToReturn.height = pokemonData.height / 10
//        pokemonToReturn.weight = pokemonData.weight / 10
//
//        // Type
//        pokemonToReturn.type = parseType(with: pokemonData)
//
//        // Genus
//        pokemonToReturn.genus = parseGenus(with: speciesData)
//
//        // Generation
//        pokemonToReturn.generation = speciesData.generation.name
//
//        // Description
//        pokemonToReturn.flavorText = parseFlavorText(with: speciesData)
//
//        // Stats
//        pokemonToReturn.stats = parseStats(with: pokemonData)
//
//        // Abilities
//        let abilities = parseAbilities(with: pokemonData)
//        for ability in abilities {
//            pokemonToReturn.addToAbilities(ability)
//        }
//
//        // Moves
//        let moves = parseMoves(with: pokemonData)
//        for move in moves {
//            pokemonToReturn.addToMoves(move)
//        }
//
//        // Alt Forms
//        if pokemonData.forms.count > 1 {
//            pokemonToReturn.hasAltForm = true
//        } else {
//            pokemonToReturn.hasAltForm = false
//        }
//
//        return pokemonToReturn
//    }
    
    func updateDetails(for pokemonManagedObjectID: NSManagedObjectID, with speciesData: SpeciesData) {
        let pokemon = backgroundContext.object(with: pokemonManagedObjectID) as! PokemonMO
        
        pokemon.managedObjectContext?.performAndWait {
            // Genus
            pokemon.genus = parseGenus(with: speciesData)
            
            // Generation
            pokemon.generation = speciesData.generation.name
            
            // Description
            pokemon.flavorText = parseFlavorText(with: speciesData)
            
            pokemon.isBaby = speciesData.isBaby
            pokemon.isLegendary = speciesData.isLegendary
            pokemon.isMythical = speciesData.isMythical
            pokemon.order = Int64(speciesData.order)
            pokemon.nationalPokedexNumber = Int64(speciesData.pokedexNumbers[0].entryNumber)
            
            pokemon.pokemonURL = speciesData.varieties[0].pokemon.url
        }
    }
    
    func updateDetails(for pokemonManagedObjectID: NSManagedObjectID, with pokemonData: PokemonData) {
        let pokemon = backgroundContext.object(with: pokemonManagedObjectID) as! PokemonMO
        
        pokemon.managedObjectContext?.performAndWait {
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
            
            // Forms
            if pokemonData.forms.count > 1 {
                pokemon.hasAltForm = true
                let altFormsArray = parseAltForms(with: pokemonData)
                pokemon.altForm = NSSet(array: altFormsArray)
            } else {
                pokemon.hasAltForm = false
            }
        }
    }
    
    func updateDetails(for pokemonManagedObjectID: NSManagedObjectID, with formData: [FormData]) {
        backgroundContext.performAndWait {
            for form in formData {
                let pokemon = backgroundContext.object(with: pokemonManagedObjectID) as! PokemonMO
                let altForm = AltFormMO(context: backgroundContext)
                
                altForm.formName = form.formName
                altForm.formOrder = Int64(form.formOrder)
                altForm.id = Int64(form.id)
                altForm.isMega = form.isMega
                altForm.name = form.name
                altForm.order = Int64(form.order)
                altForm.pokemon = pokemon
            }
        }
    }
    
    func addAbilityDescription(to abilityManagedObjectID: NSManagedObjectID, with abilityData: AbilityData) {
        let ability = backgroundContext.object(with: abilityManagedObjectID) as! AbilityMO
        
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
            print("Error parsing Pokemon Ability flavor text")
            flavorText = ""
        }
        
        ability.managedObjectContext?.performAndWait {
            ability.abilityDescription = flavorText
            ability.id = Int64(abilityData.id)
        }
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
        print("Error parsing Pokemon genus")
        return ""
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
            print("Error parsing Pokemon flavor text")
            return ""
        }
    }
    
    private func parseStats(with pokemonData: PokemonData) -> [String: Float] {
        var stats = [String: Float]()
        
        for stat in pokemonData.stats {
            stats[stat.statName] = Float(stat.baseStat)
        }
        return stats
    }
    
    private func parseAbilities(with pokemonData: PokemonData) -> [AbilityMO] {
        var abilitiesArray = [AbilityMO]()
        
        backgroundContext.performAndWait {
            for ability in pokemonData.abilities {
                let abilityMO = AbilityMO(context: backgroundContext)
                abilityMO.name = ability.name
                abilityMO.isHidden = ability.isHidden
                abilityMO.urlString = ability.url
                abilityMO.slot = Int64(ability.slot)
                
                abilitiesArray.append(abilityMO)
            }
        }
        
        return abilitiesArray
    }
    
    private func parseMoves(with pokemonData: PokemonData) -> [MoveMO] {
        var movesArray = [MoveMO]()
        
        backgroundContext.performAndWait {
            for move in pokemonData.moves {
                let moveMO = MoveMO(context: backgroundContext)
                moveMO.name = move.name
                moveMO.levelLearnedAt = Int64(move.levelLearnedAt)
                moveMO.moveLearnMethod = move.moveLearnMethod
                moveMO.urlString = move.url
                
                movesArray.append(moveMO)
            }
        }
        
        return movesArray
    }
    
    private func parseAltForms(with pokemonData: PokemonData) -> [AltFormMO] {
        var altFormsArray = [AltFormMO]()
        
        backgroundContext.performAndWait {
            let forms = pokemonData.forms.dropFirst()
            
            for form in forms {
                let altFormMO = AltFormMO(context: backgroundContext)
                altFormMO.name = form.name
                altFormMO.urlString = form.url
                altFormsArray.append(altFormMO)
            }
        }
        
        return altFormsArray
    }
    
    // MARK: - Core Data Methods
    
    func loadSavedPokemon() -> AnyPublisher<[PokemonMO], Never> {
        let request: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
        
        var pokemonToReturn = [PokemonMO]()
        
        do {
            pokemonToReturn = try self.backgroundContext.fetch(request)
            print("Successfully fetched \(pokemonToReturn.count) pokemon from Core Data")
        } catch {
            print("Fetch from Core Data failed: \(error)")
        }
        
        return Just(pokemonToReturn)
            .eraseToAnyPublisher()
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                print("MOC successfully saved")
            } catch {
                print("Error saving context to Core Data: \(error)")
            }
        }
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
