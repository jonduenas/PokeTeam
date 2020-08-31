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
    var pokemonArray = [PokemonMO]()
    var filteredPokemon = [PokemonMO]()
    var subscriptions: Set<AnyCancellable> = []
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        navigationItem.title = "POKEDEX"
        navigationItem.largeTitleDisplayMode = .always
        
        indicatorView = view.activityIndicator(style: .large, center: self.view.center)
        tableView.backgroundView = indicatorView
        
        initializeSearchBar()
        
        loadSavedData()
    }
    
    private func fetchPokedex() {
        guard let url = PokemonManager.shared.createURL(for: .allPokemon) else {
            print("Error creating URL")
            return
        }
        
        // Downloads list of all Pokemon names and URLs
        PokemonManager.shared.fetchFromAPI(of: NationalPokedex.self, from: url)
            .map({ (pokedex) -> [PokemonMO] in
                if pokedex.count == self.pokemonArray.count && pokedex.count != 0 {
                    // Saved list of Pokemon is the same as the API
                    return self.pokemonArray
                } else {
                    // Creates new list or adds new entries to saved list
                    return PokemonManager.shared.parseNationalPokedex(pokedex: pokedex)
                }
            })
            .sink(receiveCompletion: { results in
                switch results {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            },
                  receiveValue: { (pokemonArray) in
                    self.pokemonArray = pokemonArray
                    PokemonManager.shared.save()
                    self.updateUI()
            })
        .store(in: &subscriptions)
    }
    
    private func loadSavedData() {
        setState(loading: true)
        
        pokemonArray = PokemonManager.shared.loadSavedPokemon()
        
        fetchPokedex()
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.setState(loading: false)
        }
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
            return filteredPokemon.count
        }
        
        return pokemonArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: pokemonCellID, for: indexPath) as! PokemonCell
        
        let pokemon: PokemonMO
        if isFiltering {
            pokemon = filteredPokemon[indexPath.row]
        } else {
            pokemon = pokemonArray[indexPath.row]
        }
        
        cell.setPokemonInfo(for: pokemon)
        
        return cell
    }
    
    // MARK: Search Bar Methods
    
    func filterContentForSearchText(_ searchText: String) {
        filteredPokemon = searchText.isEmpty ? pokemonArray : pokemonArray.filter({ (pokemon) -> Bool in
            return pokemon.name?.range(of: searchText, options: .caseInsensitive) != nil
        })
        tableView.reloadData()
    }
    
    // MARK: Navigation Methods
    
    @IBSegueAction
    func makePokemonDetailViewController(coder: NSCoder) -> UIViewController? {
        let indexPath = tableView.indexPathForSelectedRow!
        let selectedRow = indexPath.row
        
        let pokemon: PokemonMO
        
        if isFiltering {
            pokemon = filteredPokemon[selectedRow]
        } else {
            pokemon = pokemonArray[selectedRow]
        }
        return PokemonDetailVC(coder: coder, pokemon: pokemon)
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
