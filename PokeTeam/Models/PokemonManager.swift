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

enum PokemonType: String {
    case normal, fire, water, electric, grass, ice, fighting, poison, ground, flying, psychic, bug, rock, ghost, dragon, dark, steel, fairy, unknown
}

class PokemonManager {
    static let shared = PokemonManager()
    
    func fetchFromAPI<T>(name: String? = nil, index: Int? = nil, urlString: String? = nil, dataType: PokemonDataType? = nil, decodeTo type: T.Type, completion: @escaping (T) -> Void) where T: Decodable {
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
}
