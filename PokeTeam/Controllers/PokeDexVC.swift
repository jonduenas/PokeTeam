//
//  PokeDexVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class PokeDexVC: UITableViewController, UISearchBarDelegate {
    
    let pokemonCellID = "pokemonCell"
    let navBarFont = FontKit.roundedFont(ofSize: 17, weight: .bold)
    let cellFont = FontKit.roundedFont(ofSize: 17, weight: .regular)
    
    var pokedex: Pokedex?
    var filteredPokedex = [PokemonEntry]()

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pokédex"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: navBarFont]
        
        loadPokedex()
        
        searchBar.delegate = self
    }
    
    private func loadPokedex() {
        PokemonManager.shared.fetchFromAPI(index: 1, dataType: .pokedex, decodeTo: Pokedex.self) { (pokedex) in
            DispatchQueue.main.async {
                self.pokedex = pokedex
                self.filteredPokedex = pokedex.pokemonEntries
                self.navigationItem.title = "Pokédex: \(pokedex.name.capitalized)"
                
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func selectPokedex() {
        
    }

    // MARK: Tableview Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPokedex.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: pokemonCellID, for: indexPath)
        
        let pokemonName = filteredPokedex[indexPath.row].name
        cell.textLabel?.text = pokemonName.capitalized
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let pokedex = pokedex else { return }
//        PokemonManager.shared.fetchPokemon(number: indexPath.row, from: pokedex) { (species) in
//            print(species.name)
//        }
    }
    
    // MARK: Search Bar Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let pokedex = pokedex else { return }
        filteredPokedex = searchText.isEmpty ? pokedex.pokemonEntries : pokedex.pokemonEntries.filter({ (pokemonEntry) -> Bool in
            return pokemonEntry.name.range(of: searchText, options: .caseInsensitive) != nil
        })
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    // MARK: Navigation Methods
    
    @IBSegueAction
    func makePokemonDetailViewController(coder: NSCoder) -> UIViewController? {
        let indexPath = tableView.indexPathForSelectedRow!
        let selectedRow = indexPath.row
        let pokemon = filteredPokedex[selectedRow]
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
