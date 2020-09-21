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
    let backgroundContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack
    
    // MARK: - Initializers
    public init(managedObjectContext: NSManagedObjectContext, coreDataStack: CoreDataStack) {
        self.managedObjectContext = managedObjectContext
        self.coreDataStack = coreDataStack
        
        self.backgroundContext = coreDataStack.newDerivedContext()
    }
}

extension DataManager {
    
    @discardableResult public func addPokemon(name: String, speciesURL: String, id: Int64) -> PokemonMO {
        let pokemonMO = PokemonMO(context: backgroundContext)
        pokemonMO.name = name
        pokemonMO.speciesURL = speciesURL
        pokemonMO.id = id
        
        return pokemonMO
    }
    
    @discardableResult public func updatePokedex(pokedex: NationalPokedex) -> [PokemonMO] {
        var newPokemonArray = [PokemonMO]()
        
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
        coreDataStack.saveContext(backgroundContext)
        return newPokemonArray
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
}
