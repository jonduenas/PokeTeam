//
//  PokemonManager.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import CoreData

class PokemonManager {
    static let shared = PokemonManager()
    
    // MARK: Core Data parsing methods
    
    
    
//    // MARK: - Core Data Methods
//
//    func loadSavedPokemon() -> AnyPublisher<[PokemonMO], Never> {
//        let request: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
//        let sort = NSSortDescriptor(key: "id", ascending: true)
//        request.sortDescriptors = [sort]
//
//        var pokemonToReturn = [PokemonMO]()
//
//        do {
//            pokemonToReturn = try self.backgroundContext.fetch(request)
//            print("Successfully fetched \(pokemonToReturn.count) pokemon from Core Data")
//        } catch {
//            print("Fetch from Core Data failed: \(error)")
//        }
//
//        return Just(pokemonToReturn)
//            .eraseToAnyPublisher()
//    }
//
//    func saveContext(_ context: NSManagedObjectContext) {
//        if context.hasChanges {
//            do {
//                try context.save()
//                print("MOC successfully saved")
//            } catch {
//                print("Error saving context to Core Data: \(error)")
//            }
//        }
//    }
//
//    func save() {
//        if context.hasChanges {
//            do {
//                try context.save()
//                print("MOC successfully saved.")
//            } catch {
//                print("Error saving context to Core Data: \(error)")
//            }
//        }
//    }
}
