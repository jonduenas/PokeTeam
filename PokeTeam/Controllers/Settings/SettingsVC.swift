//
//  SettingsVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 12/28/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine
import CoreData

class SettingsVC: UITableViewController {
    
    let reuseIdentifier = "SettingsCell"
    let offlineModeIndex = 0
    let clearStoredDataIndex = 1
    
    var coreDataStack: CoreDataStack!
    var apiService: APIService!
    var dataManager: DataManager!
    var tableViewCells = [String]()
    var subscriptions: Set<AnyCancellable> = []
    //var speciesData: [SpeciesData] = []
    
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
        downloadAllSpeciesData()
            .map({ _ -> [PokemonMO] in
                return self.dataManager.getFromCoreData(entity: PokemonMO.self) as! [PokemonMO]
            })
            .flatMap { allPokemonArray -> AnyPublisher<[PokemonMO], Error> in
                return allPokemonArray.publisher.setFailureType(to: Error.self)
                    .flatMap({ pokemon in
                        self.downloadPokemonData(for: pokemon)
                    })
                    .collect()
                    .eraseToAnyPublisher()
            }
            .flatMap { allPokemon -> AnyPublisher<[[AbilityDetails]], Error> in
                return allPokemon.publisher.setFailureType(to: Error.self)
                    .flatMap { pokemon -> AnyPublisher<[AbilityDetails], Error> in
                        return self.downloadAllAbilityDataFor(pokemon)
                    }.collect()
                    .eraseToAnyPublisher()
            }
            .ignoreOutput()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    let errorMessage = "Error downloading all Pokemon Data: \(error.localizedDescription)"
                    print(error)
                    DispatchQueue.main.async {
                        self.showAlert(message: errorMessage)
                    }
                case .finished:
                    self.coreDataStack.saveContext(self.dataManager.managedObjectContext)
                    
                    DispatchQueue.main.async {
                        self.clearAllTabData()
                        let finishedMessage = "Finished downloading all data"
                        print(finishedMessage)
                        self.showAlert(message: finishedMessage)
                    }
                    
                }
            } receiveValue: { _ in
                print("Finished downloading all data")
            }
            .store(in: &subscriptions)
    }
    
    func downloadAllSpeciesData() -> AnyPublisher<[PokemonMO], Error> {
        guard let speciesURL = apiService.createURL(for: .allPokemon) else {
            print("Unable to create species data url")
            return Result.Publisher([]).eraseToAnyPublisher()
        }
        // Download SpeciesData of all Pokemon Species
        return apiService.fetchAll(type: SpeciesData.self, from: speciesURL)
            .flatMap({ allSpeciesData -> AnyPublisher<[PokemonMO], Error> in
                // Iterate through each individual SpeciesData
                allSpeciesData.publisher.setFailureType(to: Error.self)
                    .map { speciesData -> PokemonMO in
                        // Create new Pokemon Managed Object
                        let pokedexNumber = speciesData.pokedexNumbers[0].entryNumber
                        let speciesURL = self.apiService.createURL(for: .species, fromIndex: pokedexNumber)!
                        let pokemon = self.dataManager.addPokemon(name: speciesData.name, speciesURL: speciesURL.absoluteString, id: speciesData.pokedexNumbers[0].entryNumber)
                        return self.dataManager.updateDetails(for: pokemon.objectID, with: speciesData)
                    }
                    .flatMap({ pokemon -> AnyPublisher<PokemonMO, Error> in
                        // Download SpeciesData for Pokemon Varieties
                        guard let pokemonVarieties = pokemon.varieties else { return Empty().eraseToAnyPublisher() }
                        let pokemonVarietiesArray = pokemonVarieties.array as! [PokemonMO]
                        
                        // Iterate through each individual variety
                        return pokemonVarietiesArray.publisher.setFailureType(to: Error.self)
                            .flatMap { pokemonVariety -> AnyPublisher<PokemonMO, Error> in
                                let speciesURL = URL(string: pokemonVariety.speciesURL!)!
                                return self.apiService.fetch(type: SpeciesData.self, from: speciesURL)
                                    .map { varietySpeciesData -> PokemonMO in
                                        let returnPokemon = self.dataManager.updateDetails(for: pokemonVariety.objectID, with: varietySpeciesData)
                                        self.coreDataStack.saveContext(self.dataManager.managedObjectContext)
                                        return returnPokemon
                                    }.eraseToAnyPublisher()
                            }.eraseToAnyPublisher()
                    })
                    .collect()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func downloadPokemonData(for pokemon: PokemonMO) -> AnyPublisher<PokemonMO, Error> {
        // Download PokemonData for new Pokemon Managed Object
        guard let pokemonURLString = pokemon.pokemonURL else { return Empty().eraseToAnyPublisher() }
        let pokemonDataURL = URL(string: pokemonURLString)!
        
        return self.apiService.fetch(type: PokemonData.self, from: pokemonDataURL)
            .map { pokemonData -> PokemonMO in
                // Update Pokemon Managed Object with PokemonData
                self.dataManager.updateDetails(for: pokemon.objectID, with: pokemonData)
                return pokemon
            }.eraseToAnyPublisher()
    }
    
    func downloadAllVarietyDataFor(_ pokemon: PokemonMO) -> AnyPublisher<[PokemonData], Error> {
        guard let pokemonVarieties = pokemon.varieties else { return Result.Publisher([]).eraseToAnyPublisher() }
        
        let pokemonVarietyArray = pokemonVarieties.array as! [PokemonMO]
        
        return pokemonVarietyArray.publisher.setFailureType(to: Error.self)
            .flatMap { pokemonVariety -> AnyPublisher<PokemonData, Error> in
                return self.apiService.fetch(type: PokemonData.self, from: URL(string: pokemonVariety.pokemonURL!)!)
            }.collect()
            .eraseToAnyPublisher()
    }
    
    func downloadAllAbilityDataFor(_ pokemon: PokemonMO) -> AnyPublisher<[AbilityDetails], Error> {
        guard let abilitiesSet = pokemon.abilities else { return Result.Publisher([]).eraseToAnyPublisher() }
        
        let abilitiesArray = abilitiesSet.array as! [AbilityMO]
        
        return abilitiesArray.publisher.setFailureType(to: Error.self)
            .flatMap { ability -> AnyPublisher<AbilityDetails, Error> in
                guard let abilityDetailsStringURL = ability.abilityDetails?.urlString else { return Empty().eraseToAnyPublisher() }
                
                return self.apiService.fetch(type: AbilityData.self, from: URL(string: abilityDetailsStringURL)!)
                    .map { abilityData -> AbilityDetails in
                        guard let abilityDetailsObject = ability.abilityDetails else { fatalError("This should always exist") }
                        return self.dataManager.addAbilityDescription(to: abilityDetailsObject.objectID, with: abilityData)
                    }.eraseToAnyPublisher()
            }.collect()
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
                self.coreDataStack.deletePersistentStore()
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
