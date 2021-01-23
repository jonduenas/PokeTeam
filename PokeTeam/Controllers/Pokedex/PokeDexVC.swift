//
//  PokedexVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine
import CoreData

class PokedexVC: UITableViewController, NSFetchedResultsControllerDelegate {
    var coreDataStack: CoreDataStack
    var dataManager: DataManager
    
    let nationalPokedexID = 1
    let pokemonCellID = "pokemonCell"
    let simpleOver = SimpleOver()
    
    var searchController: UISearchController!
    var colorBlockView: ColorBlockView!
    var indicatorView: UIActivityIndicatorView!
    private lazy var apiService = APIService()
    
    var refreshButton: UIBarButtonItem?
    var fetchedResultsController: NSFetchedResultsController<PokemonMO>!
    var filteredPokemon = [PokemonMO]()
    var subscriptions: Set<AnyCancellable> = []
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    init?(coder: NSCoder, coreDataStack: CoreDataStack, dataManager: DataManager) {
        self.coreDataStack = coreDataStack
        self.dataManager = dataManager
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeNavigationBar()
        tableView.backgroundColor = .clear

        initializeTypeCheckerTab()

        initializeIndicatorView()
        initializeSearchBar()
        
        setState(loading: true)
        
        loadPokedex()
    }
    
    // MARK: - viewDidLoad Initializer methods
    
    private func initializeIndicatorView() {
        indicatorView = view.activityIndicator(style: .large, center: self.view.center)
        navigationController?.view.insertSubview(indicatorView, at: 1)
    }
    
    private func initializeNavigationBar() {
        navigationController?.delegate = self
        navigationItem.title = "POKEDEX"
        navigationItem.largeTitleDisplayMode = .always
        
        navigationController?.navigationBar.setNavigationBarColor(to: UIColor.clear, backgroundEffect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(fetchPokedex))
    }
    
    private func initializeTypeCheckerTab() {
        if let typeObjects = dataManager.getFromCoreData(entity: TypeMO.self) as? [TypeMO] {
            if typeObjects.isEmpty {
                fetchTypeDataFromAPI()
            }
        } else {
            fetchTypeDataFromAPI()
        }
    }
    
    func fetchTypeDataFromAPI() {
        let typesURL = apiService.createURL(for: .types)!
        
        apiService.fetchAll(type: TypeData.self, from: typesURL)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished fetching all TypeData from API")
                case .failure(let error):
                    print("Error fetching all TypeData from API: \(error) - \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] allTypeData in
                guard let self = self else { return }
                self.dataManager.parseTypeDataIntoCoreData(typeDataArray: allTypeData)
                
                DispatchQueue.main.async {
                    let typeCheckerNav = self.tabBarController?.viewControllers?[2] as! CustomNavVC
                    let typeCheckerTab = typeCheckerNav.viewControllers[0] as! TypeCheckerVC
                    typeCheckerTab.allTypes = self.dataManager.getFromCoreData(entity: TypeMO.self, sortBy: "name", isAscending: true) as! [TypeMO]
                }
            }
            .store(in: &subscriptions)
    }
    
    func loadPokedex() {
        loadSavedPokedexData()
        fetchPokedex()
    }
    
    private func loadSavedPokedexData() {
        print("Loading from Core Data")
        if fetchedResultsController == nil {
            let request: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
            
            let filter = NSPredicate(format: "isAltVariety == NO")
            request.predicate = filter
            
            let sort = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sort]
            
            request.fetchBatchSize = 20
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        do {
            try fetchedResultsController.performFetch()
            print("Core Data fetch succssful")
        } catch {
            print("Core Data fetch failed - \(error)")
        }
    }
    
    @objc private func fetchPokedex() {
        setState(loading: true)
        
        guard let url = apiService.createURL(for: .allPokemon) else {
            print("Error creating URL")
            return
        }
        
        // Downloads list of all Pokemon names and URLs
        apiService.fetch(type: ResourceList.self, from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished fetching from API")
                    break
                case .failure(let error):
                    print("Error fetching from API: \(error) - \(error.localizedDescription)")
                    self.updateUI(error: error)
                }
            }, receiveValue: { [weak self] pokedex in
                guard let managedObjects = self?.fetchedResultsController.fetchedObjects else { return }
                
                if self?.shouldUpdateWithAPI(pokedex: pokedex, managedObjects: managedObjects) ?? false {
                    let difference = pokedex.count - managedObjects.count
                    print("Found \(difference) more Pokemon on the API - Should update.")
                    
                    self?.dataManager.updatePokedex(pokedex: pokedex)
                    self?.loadSavedPokedexData()
                } else {
                    print("Stored Pokemon count matches API - Should skip update")
                }
                
                self?.updateUI()
        })
        .store(in: &subscriptions)
    }
    
    private func shouldUpdateWithAPI(pokedex: ResourceList, managedObjects: [NSManagedObject]) -> Bool {
        // If the count from the API is different from the count in Core Data OR if the Core Data count is 0 - return true
        return pokedex.count != managedObjects.count || managedObjects.isEmpty
    }
    
    private func updateUI(error: Error? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("Updating UI")
            if let error = error {
                self.showAlert(message: "Error downloading data from server: \(error.localizedDescription)")
                self.navigationItem.rightBarButtonItem = self.refreshButton
                self.setState(loading: false)
                return
            }
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.reloadData()
            self.setState(loading: false)
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
        navigationItem.hidesSearchBarWhenScrolling = false
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: pokemonCellID, for: indexPath) as! PokemonTableCell
        
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
            return pokemon.name?.formatPokemonName().range(of: searchText, options: .caseInsensitive) != nil
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
        return PokemonDetailVC(coder: coder, pokemonObjectID: pokemon, coreDataStack: coreDataStack, dataManager: dataManager, apiService: apiService)
    }
    
    private func setState(loading: Bool) {
        if loading {
            indicatorView.startAnimating()
        } else {
            indicatorView.stopAnimating()
        }
    }
}

extension PokedexVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension PokedexVC: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        simpleOver.popStyle = (operation == .pop)
        return simpleOver
    }
}
