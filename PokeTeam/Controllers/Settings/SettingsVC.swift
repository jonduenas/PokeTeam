//
//  SettingsVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 12/28/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine

class SettingsVC: UITableViewController {
    
    let reuseIdentifier = "SettingsCell"
    let offlineModeIndex = 0
    let clearStoredDataIndex = 1
    
    var coreDataStack: CoreDataStack!
    var apiService: APIService!
    var dataManager: DataManager!
    var tableViewCells = [String]()
    var subscriptions: Set<AnyCancellable> = []
    var speciesData: [SpeciesData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewCells = [
            "Download Data for Offline Use",
            "Reset All Stored Data"
        ]
    }
    
    private func clearAllTabData() {
        let pokedexNav = tabBarController?.viewControllers?[0] as! CustomNavVC
        let pokedexTab = pokedexNav.viewControllers[0] as! PokeDexVC
        pokedexNav.popToRootViewController(animated: false)
        try? pokedexTab.fetchedResultsController.performFetch()
        pokedexTab.loadPokedex()
        pokedexTab.fetchTypeDataFromAPI()
        
        let teamNav = tabBarController?.viewControllers?[1] as! CustomNavVC
        let teamTab = teamNav.viewControllers[0] as! TeamBuilderViewController
        teamTab.reloadTeam()
        
        let typeCheckerNav = tabBarController?.viewControllers?[2] as! CustomNavVC
        let typeCheckerTab = typeCheckerNav.viewControllers[0] as! TypeCheckerVC
        typeCheckerTab.reloadData()
    }
    
    private func downloadAndStoreAllData() {
//        print("Downloading and storing all data from server")
//        guard let speciesURL = apiService.createURL(for: .species) else { return }
//
//        //var allSpeciesData = [SpeciesData]()
//
//        apiService.fetchAll(type: SpeciesData.self, from: speciesURL)
//            .flatMap { allSpeciesData -> AnyPublisher<[PokemonData], Error> in
//                return allSpeciesData.publisher
//                    .map(\.varieties)
//                    .flatMap { varieties -> AnyPublisher<[PokemonData], Error> in
//                        return varieties.publisher
//                            .flatMap { variety in
//                                self.apiService.fetch(type: PokemonData.self, from: URL(string: variety.pokemon.url)!)
//                            }
//                            .collect()
//                            .eraseToAnyPublisher()
//                    }
//                    .eraseToAnyPublisher()
//            }
//            .sink { completion in
//                switch completion {
//                case .finished:
//                    print("Finished fetching all TypeData from API")
//                case .failure(let error):
//                    print("Error fetching all SpeciesData from API: \(error) - \(error.localizedDescription)")
//                }
//            } receiveValue: { pokemonDataArray in
//
//            }
//            .store(in: &subscriptions)
        
        downloadAllSpeciesData()
            .flatMap { allSpeciesData in
                allSpeciesData.publisher.eraseToAnyPublisher()
            }
            .flatMap { speciesData -> AnyPublisher<[PokemonData], Error> in
                let pokedexNumber = speciesData.pokedexNumbers[0].entryNumber
                let speciesURL = self.apiService.createURL(for: .species, fromIndex: pokedexNumber)!
                self.dataManager.addPokemon(name: speciesData.name, speciesURL: speciesURL.absoluteString, id: speciesData.pokedexNumbers[0].entryNumber)
                return self.downloadAllPokemonDataFor(species: speciesData)
                    .flatMap { allVarietyData in
                        return allVarietyData.publisher.eraseToAnyPublisher()
                    }
                    .flatMap { pokemonData -> AnyPublisher<[AbilityData], Error> in
                        
                        return self.downloadAllAbilityDataFor(pokemon: pokemonData)
                    }.eraseToAnyPublisher()
            }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func downloadAllSpeciesData() -> AnyPublisher<[SpeciesData], Error> {
        guard let speciesURL = apiService.createURL(for: .species) else {
            print("Unable to create species data url")
            return Result.Publisher([]).eraseToAnyPublisher()
        }
        return apiService.fetchAll(type: SpeciesData.self, from: speciesURL)
        // TODO: .map and transform species data to Pokemon object and return publisher with [PokemonMO]
    }
    
    func downloadAllPokemonDataFor(species: SpeciesData) -> AnyPublisher<[PokemonData], Error> {
        return species.varieties.publisher
            .flatMap { variety in
                self.apiService.fetch(type: PokemonData.self, from: URL(string: variety.pokemon.url)!)
            }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func downloadAllAbilityDataFor(pokemon: PokemonData) -> AnyPublisher<[AbilityData], Error> {
        return pokemon.abilities.publisher
            .flatMap({ ability in
                self.apiService.fetch(type: AbilityData.self, from: URL(string: ability.url)!)
            })
            .collect()
            .eraseToAnyPublisher()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCells.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        cell.textLabel?.text = tableViewCells[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case offlineModeIndex:
            print("Cache all data")
            let alertController = UIAlertController(title: tableViewCells[indexPath.row], message: "This will download ALL relevant data from the server and store it locally for offline usage. Depending on your connection, this may take some time. Would you like to proceed?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.downloadAndStoreAllData()
            }))
            present(alertController, animated: true)
        case clearStoredDataIndex:
            print("Clear All Stored Data")
            let alertController = UIAlertController(title: "Delete All Stored Data", message: "Do you want to delete all currently stored Pokemon data? This will require you to download the data from the server again, AND your saved team will be deleted forever. Be SURE you're ok with this.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                print("Deleting all store data")
                self.coreDataStack.deletePersistentStore()
                self.clearAllTabData()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true)
        default:
            break
        }
    }
}
