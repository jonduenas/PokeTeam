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

class PokeDexVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let nationalPokedexID = 1
    let pokemonCellID = "pokemonCell"
    
    var searchController: UISearchController!
    var indicatorView: UIActivityIndicatorView!
    
    //var pokedex: Pokedex?
    var fetchedResultsController: NSFetchedResultsController<PokemonMO>!
    //var pokemonArray = [PokemonMO]()
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
        
        setState(loading: true)
        loadSavedData()
        fetchPokedex()
    }
    
    private func loadSavedData() {
        print("Loading from Core Data")
        if fetchedResultsController == nil {
            let request: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
            let sort = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: PokemonManager.shared.context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        do {
            try fetchedResultsController.performFetch()
            print("Core Data fetch succssful")
        } catch {
            print("Core Data fetch failed - \(error)")
        }
        
//        PokemonManager.shared.loadSavedPokemon()
//            .flatMap({ (pokemonMOArray) in
//                return pokemonMOArray.publisher
//                    .map { (pokemonBGContext) -> PokemonMO in
//                        return PokemonManager.shared.context.object(with: pokemonBGContext.objectID) as! PokemonMO
//                }
//            .collect()
//            })
//            .sink(receiveValue: { (cdPokemonArray) in
//                self.pokemonArray = cdPokemonArray
//                self.fetchPokedex()
//            })
//        .store(in: &subscriptions)
    }
    
    private func fetchPokedex() {
        guard let url = PokemonManager.shared.createURL(for: .allPokemon) else {
            print("Error creating URL")
            return
        }
        
        // Downloads list of all Pokemon names and URLs
        PokemonManager.shared.fetchFromAPI(of: NationalPokedex.self, from: url)
            .flatMap({ pokedex in
                return self.shouldUpdateWithAPI(pokedex: pokedex).map { (pokedex, $0) } })
            .flatMap({ (pokedex, shouldUpdate) -> AnyPublisher<Bool, Error> in
                if shouldUpdate {
                    print("Updating Pokedex with API")
                    return PokemonManager.shared.updateNationalPokedex(pokedex: pokedex)
                } else {
                    print("Skipping update and using local data")
                    return Just(shouldUpdate).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
            })
            .sink(receiveCompletion: { results in
                switch results {
                case .finished:
                    print("Finished updating Pokemon.")
                    break
                case .failure(let error):
                    print(error)
                }
            },
                  receiveValue: { (pokedexUpdated) in
                    if pokedexUpdated {
                        // Core Data was updated - reload with new data
                        self.loadSavedData()
                        self.updateUI()
                    } else {
                        // Core Data is already up to date - skip reloading
                        self.updateUI()
                    }
            })
        .store(in: &subscriptions)
    }
    
    private func shouldUpdateWithAPI(pokedex: NationalPokedex) -> AnyPublisher<Bool, Error> {
        guard let managedObjects = fetchedResultsController.fetchedObjects else {
            // If for some reason this is nil, just load from the API again
            return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        if pokedex.count == managedObjects.count && managedObjects.count != 0 {
            // Pokemon count from Core Data is the same as the Pokemon count from the API - skip updating
            print("Stored Pokemon count matches API - Should skip update")
            return Just(false).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            // Should update with API
            let difference = pokedex.count - managedObjects.count
            print("Found \(difference) more Pokemon on the API - Should update.")
            return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
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
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: pokemonCellID, for: indexPath) as! PokemonCell
        
        let pokemon: PokemonMO
        if isFiltering {
            pokemon = filteredPokemon[indexPath.row]
        } else {
            pokemon = fetchedResultsController.object(at: indexPath)
        }
        
        cell.setPokemonInfo(for: pokemon)
        
        return cell
    }
    
    // MARK: Search Bar Methods
    
    func filterContentForSearchText(_ searchText: String) {
        filteredPokemon = (searchText.isEmpty ? fetchedResultsController.fetchedObjects : fetchedResultsController.fetchedObjects!.filter({ (pokemon) -> Bool in
            return pokemon.name?.range(of: searchText, options: .caseInsensitive) != nil
        }))!
        tableView.reloadData()
    }
    
    // MARK: Navigation Methods
    
    @IBSegueAction
    func makePokemonDetailViewController(coder: NSCoder) -> UIViewController? {
        let indexPath = tableView.indexPathForSelectedRow!
        let selectedRow = indexPath.row
        
        let pokemon: NSManagedObjectID
        
        if isFiltering {
            pokemon = filteredPokemon[selectedRow].objectID
        } else {
            pokemon = fetchedResultsController.object(at: indexPath).objectID
        }
        return PokemonDetailVC(coder: coder, pokemonObjectID: pokemon)
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
