//
//  PokemonTeam.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/22/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

class PokemonTeam {
    var team: [Pokemon]
    var isAddAllowed: Bool
    
    init() {
        // Load saved team
        
        // If no saved team exists
        self.team = []
        self.isAddAllowed = true
    }
    
    func add(_ pokemon: Pokemon) -> [Bool: String] {
        let success: Bool
        let successMessage = "Successfully added \(pokemon.name.capitalized) to team."
        let failedMessage = "Unable to add \(pokemon.name.capitalized) to team. Six is the maximum allowed."
        
        if isAddAllowed {
            success = true
            team.append(pokemon)
            if team.count == 6 {
                isAddAllowed = false
            }
            return [success: successMessage]
        } else {
            success = false
            return [success: failedMessage]
        }
    }
    
    func remove(_ pokemon: Pokemon) -> [Bool: String] {
        let success: Bool
        let successMessage = "Successfully removed \(pokemon.name.capitalized) from team."
        let failedMessage = "There was an error removing \(pokemon.name.capitalized) from team."
        
        let pokemonToRemove = pokemon.id
        let currentTeamCount = team.count
        
        team.removeAll { (teamPokemon) -> Bool in
            teamPokemon.id == pokemonToRemove
        }
        
        if team.count < currentTeamCount {
            success = true
            print("pokemon removed")
            print("team count: \(team.count)")
            return [success: successMessage]
        } else {
            success = false
            return [success: failedMessage]
        }
    }
}
