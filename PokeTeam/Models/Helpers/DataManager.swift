//
//  DataManager.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/9/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation
import CoreData

public final class DataManager {
    // MARK: - Properties
    let managedObjectContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack
    
    // MARK: - Initializers
    public init(managedObjectContext: NSManagedObjectContext, coreDataStack: CoreDataStack) {
        self.managedObjectContext = managedObjectContext
        self.coreDataStack = coreDataStack
    }
}

extension DataManager {
    
    @discardableResult public func addPokemon(name: String, varietyName: String? = nil, speciesURL: String, pokemonURL: String? = nil, id: Int64) -> PokemonMO {
        let pokemonMO = PokemonMO(context: managedObjectContext)
        
        pokemonMO.speciesURL = speciesURL
        pokemonMO.id = id
        pokemonMO.name = name
        
        if varietyName != nil {
            pokemonMO.varietyName = varietyName
        }
        
        if let pokemonURL = pokemonURL {
            pokemonMO.pokemonURL = pokemonURL
        }
        
        return pokemonMO
    }
    
    @discardableResult public func addTeam() -> TeamMO {
        let team = TeamMO(context: managedObjectContext)
        
        return team
    }
    
    @discardableResult public func updatePokedex(pokedex: NationalPokedex) -> [PokemonMO] {
        var newPokemonArray = [PokemonMO]()
        
        managedObjectContext.performAndWait {
            for pokemon in pokedex.results {
                // Check if Pokemon already exists in Core Data
                let isFound = checkCDForMatch(with: pokemon)
                
                if isFound {
                    // Pokemon with matching name is found
                    continue
                } else {
                    // No Pokemon with that name is found - create a new one
                    guard let id = getID(from: pokemon.url) else { continue }
                    
                    let newPokemon = addPokemon(name: pokemon.name, speciesURL: pokemon.url, id: Int64(id))
                    newPokemonArray.append(newPokemon)
                }
            }
            print("Finished updating Pokedex")
            coreDataStack.saveContext(managedObjectContext)
        }
        
        return newPokemonArray
    }
    
    private func checkCDForMatch(with pokemon: NameAndURL) -> Bool {
        var isFound: Bool = false
        
        let pokemonRequest: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
        pokemonRequest.predicate = NSPredicate(format: "name == %@", pokemon.name)
        
        if let pokemonFetched = try? managedObjectContext.fetch(pokemonRequest) {
            if pokemonFetched.count > 0 {
                // Pokemon already exists in Core Data
                isFound = true
            }
        }
        
        return isFound
    }
    
    private func getID(from url: String) -> Int? {
        let baseURL = "https://pokeapi.co/api/v2/"
        let speciesEndpoint = "pokemon-species/"
        let pokemonEndpoint = "pokemon/"
        
        if url.contains(speciesEndpoint) {
            if let returnInt = Int(url.dropFirst(baseURL.count + speciesEndpoint.count).dropLast()) {
                return returnInt
            } else {
                print("Error getting ID from URL")
                return nil
            }
        } else if url.contains(pokemonEndpoint) {
            if let returnInt = Int(url.dropFirst(baseURL.count + pokemonEndpoint.count).dropLast()) {
                return returnInt
            } else {
                print("Error getting ID from URL")
                return nil
            }
        } else {
            print("Error getting ID from URL")
            return nil
        }
    }
    
    public func getFromCoreData<T: NSManagedObject>(entity: T.Type, sortBy: String? = nil, isAscending: Bool = true, predicate: NSPredicate? = nil) -> [Any]?  {
        let request = T.fetchRequest()
        
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        
        if (sortBy != nil) {
            let sorter = NSSortDescriptor(key: sortBy, ascending: isAscending)
            request.sortDescriptors = [sorter]
        }
        
        do {
            let fetchedResult = try managedObjectContext.fetch(request)
            print("retrieved \(fetchedResult.count) elements for \(entity)")
            return fetchedResult
        } catch {
            print("Error loading from Core Data - \(error) - \(error.localizedDescription)")
        }
        return nil
    }
    
    @discardableResult func updateDetails(for pokemonManagedObjectID: NSManagedObjectID, with speciesData: SpeciesData) -> PokemonMO {
        let pokemon = managedObjectContext.object(with: pokemonManagedObjectID) as! PokemonMO
        
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
            
            if !speciesData.pokedexNumbers.isEmpty {
                pokemon.nationalPokedexNumber = Int64(speciesData.pokedexNumbers[0].entryNumber)
            }
            
            if let speciesOrder = speciesData.order {
                pokemon.order = Int64(speciesOrder)
            }
            
            // Extract pokemon url from varieties if empty or nil
            if pokemon.pokemonURL == "" {
                for variety in speciesData.varieties {
                    if variety.pokemon.name == pokemon.name {
                        pokemon.pokemonURL = variety.pokemon.url
                    }
                    
                    if variety.isDefault {
                        pokemon.defaultVarietyURL = variety.pokemon.url
                    }
                }
            }
            
            if pokemon.pokemonURL == "" {
                // Covers rare occasions where default form name is different from species name, i.e. aegislash vs aegislash-shield, and the above loop can't find a match
                pokemon.pokemonURL = pokemon.defaultVarietyURL
            }
            
            if pokemon.varieties?.count == 0 || pokemon.varieties == nil {
                // Skips adding varieties for Pikachu since they're not true alt varieties and are only costumes
                if pokemon.name != "pikachu" {
                    var varieties = parseVarieties(with: speciesData, speciesURL: pokemon.speciesURL!)
                    
                    // Remove variety if it's the same as current Pokemon
                    for (index, variety) in varieties.enumerated() {
                        if variety.pokemonURL == pokemon.pokemonURL {
                            varieties.remove(at: index)
                        }
                    }
                    pokemon.varieties = NSOrderedSet(array: varieties)
                }
            }
        }
        coreDataStack.saveContext(managedObjectContext)
        return pokemon
    }
    
    @discardableResult func updateDetails(for pokemonManagedObjectID: NSManagedObjectID, with pokemonData: PokemonData) -> PokemonMO {
        let pokemon = managedObjectContext.object(with: pokemonManagedObjectID) as! PokemonMO
        
        pokemon.managedObjectContext?.performAndWait {
            pokemon.varietyName = pokemonData.name
            
            if pokemon.imageID == "" || pokemon.imageID == nil {
                if let speciesName = pokemon.name {
                    pokemon.imageID = pokemon.name?.replacingOccurrences(of: speciesName, with: String(pokemon.nationalPokedexNumber))
                } else {
                    pokemon.imageID = "substitute"
                }
            }
            
            pokemon.height = pokemonData.height / 10
            pokemon.weight = pokemonData.weight / 10
            
            // Type
            pokemon.type = parseType(with: pokemonData)
            
            // Stats
            pokemon.stats = parseStats(with: pokemonData)
            
            // Abilities
            let abilities = parseAbilities(with: pokemonData)
            pokemon.abilities = NSOrderedSet(array: abilities)
            
            // Moves
            let moves = parseMoves(with: pokemonData)
            pokemon.moves = NSOrderedSet(array: moves)
            
            // Forms
            if pokemonData.forms.count > 1 {
                pokemon.hasAltForm = true
                let altFormsArray = parseAltForms(with: pokemonData)
                pokemon.altForm = NSOrderedSet(array: altFormsArray)
            } else {
                pokemon.hasAltForm = false
            }
        }
        coreDataStack.saveContext(managedObjectContext)
        return pokemon
    }
    
    @discardableResult func updateDetails(for altFormManagedObjectID: NSManagedObjectID, with formData: FormData) -> AltFormMO {
        let altForm = managedObjectContext.object(with: altFormManagedObjectID) as! AltFormMO
        
        managedObjectContext.performAndWait {
            altForm.formName = formData.formName
            altForm.formOrder = Int64(formData.formOrder)
            altForm.id = Int64(formData.id)
            altForm.isMega = formData.isMega
            altForm.name = formData.name
            altForm.order = Int64(formData.order)
        }
        coreDataStack.saveContext(managedObjectContext)
        return altForm
    }
    
    @discardableResult func addAbilityDescription(to abilityDetailObjectID: NSManagedObjectID, with abilityData: AbilityData) -> AbilityDetails {
        let ability = managedObjectContext.object(with: abilityDetailObjectID) as! AbilityDetails
        
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
        coreDataStack.saveContext(managedObjectContext)
        return ability
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
    
    private func parseFlavorText(with speciesData: SpeciesData) -> [String: [String]] {
        var englishFlavorTexts = [String: [String]]()
        
        for entry in speciesData.flavorTextEntries {
            if entry.language == "en" {
                var flavorText = entry.flavorText.replacingOccurrences(of: "-\n", with: "-")
                flavorText = flavorText.replacingOccurrences(of: "\\s", with: " ", options: .regularExpression)
                
                if englishFlavorTexts[entry.version] == nil {
                    englishFlavorTexts[entry.version] = [flavorText]
                } else {
                    englishFlavorTexts[entry.version]?.append(flavorText)
                }
            } else {
                continue
            }
        }
        return englishFlavorTexts
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
        
        for ability in pokemonData.abilities {
            let abilityMO = AbilityMO(context: managedObjectContext)
            abilityMO.name = "\(pokemonData.name)-\(ability.name)"
            abilityMO.isHidden = ability.isHidden
            abilityMO.slot = Int64(ability.slot)
            
            let abilityDetails = AbilityDetails(context: managedObjectContext)
            abilityDetails.urlString = ability.url
            abilityDetails.name = ability.name
            
            abilityMO.abilityDetails = abilityDetails
            
            abilitiesArray.append(abilityMO)
        }
        
        return abilitiesArray
    }
    
    private func parseMoves(with pokemonData: PokemonData) -> [MoveMO] {
        var movesArray = [MoveMO]()
        
        for move in pokemonData.moves {
            let moveMO = MoveMO(context: managedObjectContext)
            moveMO.name = move.name
            moveMO.levelLearnedAt = Int64(move.levelLearnedAt)
            moveMO.moveLearnMethod = move.moveLearnMethod
            moveMO.urlString = move.url
            
            movesArray.append(moveMO)
        }
        
        return movesArray
    }
    
    private func parseAltForms(with pokemonData: PokemonData) -> [AltFormMO] {
        var altFormsArray = [AltFormMO]()
        
        managedObjectContext.performAndWait {
            let forms = pokemonData.forms.dropFirst()
            
            for form in forms {
                let altFormMO = AltFormMO(context: managedObjectContext)
                altFormMO.name = form.name
                altFormMO.urlString = form.url
                altFormsArray.append(altFormMO)
            }
        }
        
        return altFormsArray
    }
    
    private func parseVarieties(with speciesData: SpeciesData, speciesURL: String) -> [PokemonMO] {
        var pokemonVarieties = [PokemonMO]()
        
        for variety in speciesData.varieties {
            // Filter out totem varieties
            if variety.pokemon.name.hasSuffix("totem") || variety.pokemon.name.hasSuffix("totem-alola") {
                continue
            }
            
            if let varietyID = getID(from: variety.pokemon.url) {
                
                let pokemonVariety = addPokemon(name: speciesData.name, varietyName: variety.pokemon.name, speciesURL: speciesURL, pokemonURL: variety.pokemon.url, id: Int64(varietyID))
                
                pokemonVariety.imageID = pokemonVariety.varietyName?.replacingOccurrences(of: speciesData.name, with: String(speciesData.pokedexNumbers[0].entryNumber))
                
                pokemonVariety.isAltVariety = !variety.isDefault
                
                pokemonVarieties.append(pokemonVariety)
            }
        }
        return pokemonVarieties
    }
}
