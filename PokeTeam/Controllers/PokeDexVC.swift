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
    let navBarFont = FontKit.roundedFont(ofSize: 17, weight: .bold)
    let cellFont = FontKit.roundedFont(ofSize: 17, weight: .regular)
    
    var pokedex: Pokedex?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pokédex"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: navBarFont]
        
        loadPokedex()
        
//        pokemon = Pokemon(id: 1, name: "", type: [""], region: "", spriteStringURL: "", statHP: 1, statAttack: 1, statDefense: 1, statSpAttack: 1, statSpDefense: 1, statSpeed: 1, abilities: ["":""])
    }
    
    private func loadPokedex() {
        PokemonManager.shared.fetchFromAPI(index: 1, dataType: .pokedex, decodeTo: Pokedex.self) { (pokedex) in
            DispatchQueue.main.async {
                self.pokedex = pokedex
                
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func selectPokedex() {
        
    }

    // MARK: Tableview Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pokedex?.pokemonEntries.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: pokemonCellID, for: indexPath)
        
        if let pokedex = pokedex {
            let pokemonName = pokedex.pokemonEntries[indexPath.row].name
            cell.textLabel?.text = pokemonName.capitalized
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let pokedex = pokedex else { return }
//        PokemonManager.shared.fetchPokemon(number: indexPath.row, from: pokedex) { (species) in
//            print(species.name)
//        }
    }
    
    // MARK: Navigation Methods
    
    @IBSegueAction
    func makePokemonDetailViewController(coder: NSCoder) -> UIViewController? {
        let indexPath = tableView.indexPathForSelectedRow!
        let selectedRow = indexPath.row
        let pokemon = pokedex!.pokemonEntries[selectedRow]
        return PokemonDetailVC(coder: coder, pokemon: pokemon)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let indexPath = tableView.indexPathForSelectedRow {
//            let selectedRow = indexPath.row
//            let detailVC = segue.destination as! PokemonDetailVC
//            detailVC.pokemon = pokedex?.pokemonEntries[selectedRow]
//        }
//    }

}

