//
//  PokeDexVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class PokeDexVC: UITableViewController {
    
    let pokemonCellID = "pokemonCell"
    
    var pokedex: Pokedex?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPokedex()
    }
    
    private func loadPokedex() {
        PokemonManager.shared.fetchPokedex(name: "national") { (pokedex) in
            DispatchQueue.main.async {
                self.pokedex = pokedex
                self.tableView.reloadData()
            }
        }
    }

    // MARK: Tableview Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pokedex?.pokemonEntries.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: pokemonCellID, for: indexPath)
        
        if let pokedex = pokedex {
            let pokemonName = pokedex.pokemonEntries[indexPath.row].pokemonSpecies.name
            cell.textLabel?.text = pokemonName.capitalized
        }
        
        return cell
    }
}

