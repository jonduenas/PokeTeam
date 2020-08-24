//
//  PokeDexVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine

class PokeDexVC: UITableViewController {
    
    let nationalPokedexID = 1
    let pokemonCellID = "pokemonCell"
    
    var searchController: UISearchController!
    var indicatorView: UIActivityIndicatorView!
    
    var pokedex: Pokedex?
    var filteredPokedex = [PokemonEntry]()
    var cancellable: AnyCancellable?
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "POKEDEX"
        navigationItem.largeTitleDisplayMode = .always
        
        indicatorView = view.activityIndicator(style: .large, center: self.view.center)
        tableView.backgroundView = indicatorView
        
        loadPokedex()
        initializeSearchBar()
    }
    
    private func loadPokedex() {
        guard let url = PokemonManager.shared.createURL(for: .pokedex, fromIndex: nationalPokedexID) else {
            print("Error creating URL")
            return
        }
        
        setState(loading: true)
        
        cancellable = PokemonManager.shared.fetchFromAPI(of: Pokedex.self, from: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { (pokedex) in
                    self.pokedex = pokedex
                    self.navigationItem.title = "POKEDEX: \(pokedex.name.capitalized)"
                    self.tableView.reloadData()
                    self.setState(loading: false)
            })
    }
    
    private func initializeSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pokémon"
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = true
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchBar.barTintColor = UIColor.label
        searchController.searchBar.tintColor = UIColor.label
    }

    // MARK: Tableview Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPokedex.count
        }
        
        return pokedex?.pokemonEntries.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: pokemonCellID, for: indexPath) as! PokemonCell
        if let pokedex = pokedex {
            let pokemon: PokemonEntry
            if isFiltering {
                pokemon = filteredPokedex[indexPath.row]
            } else {
                pokemon = pokedex.pokemonEntries[indexPath.row]
            }
            cell.setPokemonInfo(for: pokemon)
        }
        return cell
    }
    
    // MARK: Search Bar Methods
    
    func filterContentForSearchText(_ searchText: String) {
        guard let pokedex = pokedex else { return }
        filteredPokedex = searchText.isEmpty ? pokedex.pokemonEntries : pokedex.pokemonEntries.filter({ (pokemonEntry) -> Bool in
            return pokemonEntry.name.range(of: searchText, options: .caseInsensitive) != nil
        })
        tableView.reloadData()
    }
    
    // MARK: Navigation Methods
    
    @IBSegueAction
    func makePokemonDetailViewController(coder: NSCoder) -> UIViewController? {
        let indexPath = tableView.indexPathForSelectedRow!
        let selectedRow = indexPath.row
        
        guard let pokedex = pokedex else { return nil }
        
        let pokemonEntry: PokemonEntry
        
        if isFiltering {
            pokemonEntry = filteredPokedex[selectedRow]
        } else {
            pokemonEntry = pokedex.pokemonEntries[selectedRow]
        }
        return PokemonDetailVC(coder: coder, pokemonEntry: pokemonEntry)
    }
    
    private func setState(loading: Bool) {
        if loading {
            indicatorView.startAnimating()
        } else {
            indicatorView.stopAnimating()
        }
    }
}

extension PokeDexVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
