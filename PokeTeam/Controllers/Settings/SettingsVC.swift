//
//  SettingsVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 12/28/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
    
    let reuseIdentifier = "SettingsCell"
    let offlineModeIndex = 0
    let clearStoredDataIndex = 1
    
    var coreDataStack: CoreDataStack!
    var tableViewCells = [String]()
    
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
