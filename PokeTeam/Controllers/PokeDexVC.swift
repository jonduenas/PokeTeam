//
//  PokeDexVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine
import CoreData

class PokeDexVC: UITableViewController {
    
    let nationalPokedexID = 1
    let pokemonCellID = "pokemonCell"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        
        fetchPokedex()
        //loadSavedData()
    }
    
    private func fetchPokedex() {
//        guard let url = PokemonManager.shared.createURL(for: .pokedex, fromIndex: nationalPokedexID) else {
//            print("Error creating URL")
//            return
//        }
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=2000")!
        
        setState(loading: true)
        
        // Downloads ALL Pokemon Data
        PokemonManager.shared.fetchFromAPI(of: NationalPokedex.self, from: url)
            .map { (pokedex) -> [String] in
                var urlArray = [String]()
                for result in pokedex.results {
                    urlArray.append(result.url)
                }
                return urlArray
        }
        .flatMap { (urlArray) -> AnyPublisher<[PokemonData], Error> in
            let pokemonData = urlArray.map { self.fetchPokemon(with: $0) }
            return Publishers.MergeMany(pokemonData)
                .collect()
                .eraseToAnyPublisher()
        }
        .map({ (pokemonDataArray) -> [PokemonMO] in
            return pokemonDataArray.map { PokemonManager.shared.parsePokemonData(pokemonData: $0) }
        })
            .sink(receiveCompletion: { results in
                switch results {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { (pokemonArray) in
                self.saveCoreData()
                self.loadSavedData()
            })
            .store(in: &subscriptions)
        
//        PokemonManager.shared.fetchFromAPI(of: NationalPokedex.self, from: url)
//            .sink(receiveCompletion: { results in
//                switch results {
//                case .finished:
//                    break
//                case .failure(let error):
//                    print(error)
//                }
//            },
//                  receiveValue: { (pokedex) in
//                    var urlArray = [String]()
//                    for result in pokedex.results {
//                        urlArray.append(result.url)
//                    }
//            })
//        .store(in: &subscriptions)
    }
    
    private func fetchPokemon(with url: String) -> AnyPublisher<PokemonData, Error> {
        let pokemonURL = URL(string: url)!
            
        return PokemonManager.shared.fetchFromAPI(of: PokemonData.self, from: pokemonURL)
    }
    
    private func loadSavedData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let request: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
            let sort = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sort]
            
            do {
                self.pokemonArray = try self.context.fetch(request)
                print("Got \(self.pokemonArray.count) pokemon")
                self.tableView.reloadData()
                self.setState(loading: false)
            } catch {
                print("Fetch from Core Data failed: \(error)")
            }
        }
    }
    
    func saveCoreData() {
        do {
            try context.save()
        } catch {
            print("Error saving: \(error)")
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
        
        cell.pokemonNameLabel.text = pokemon.name?.capitalized
        cell.pokemonImageView.image = UIImage(named: pokemon.name ?? "1")
        
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
