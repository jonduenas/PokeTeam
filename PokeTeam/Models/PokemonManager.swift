//
//  Service.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class PokemonManager {
    static let shared = PokemonManager()
    let baseStringURL = "https://pokeapi.co/api/v2/"
    let dexStringURL = "pokedex/"
    let pokemonStringURL = "pokemon/"
    let engLang = 2
    
    func fetchPokedex(name: String, completion: @escaping (Pokedex) -> Void) {
        guard let url = URL(string: baseStringURL + dexStringURL + name) else { return }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Failed to fetch data with error: ", error!.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            
            do {
                let pokedex = try decoder.decode(Pokedex.self, from: data)
                completion(pokedex)
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
