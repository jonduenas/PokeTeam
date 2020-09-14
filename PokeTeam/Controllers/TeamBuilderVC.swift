//
//  TeamBuilderVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/8/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "PokemonCollectionCell"
private let segueIdentifier = "detailSegue"

class TeamBuilderVC: UICollectionViewController {

    let simpleOver = SimpleOver()
    let testArray = ["Pokemon 1", "Pokemon 2", "Pokemon 3"]
    var teamsArray = [TeamMO]()
    var team = [PokemonMO]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        navigationItem.title = "TEAM BUILDER"
        navigationController?.navigationBar.setNavigationBarColor(to: UIColor(named: "team-builder"))
        
        collectionView.backgroundView = UIImageView(image: UIImage(named: "team-background"))
        collectionView.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadSavedTeam()
    }

    private func loadSavedTeam() {
        print("attempting load of team")
        
        let request: NSFetchRequest<TeamMO> = TeamMO.fetchRequest()
        
        do {
            teamsArray = try PokemonManager.shared.context.fetch(request)
            if teamsArray.count > 0 {
                print("Found \(teamsArray.count) stored teams")
                let firstTeam = teamsArray[0]
                let teamSet = firstTeam.members
                team = teamSet?.array as! [PokemonMO]
                //team = teamSet?.allObjects as! [PokemonMO]
            }
        } catch {
            print("Team fetch failed: \(error)")
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = collectionView.indexPathsForSelectedItems!
        let selectedItem = indexPath[0].row
        
        if segue.identifier == segueIdentifier {
            let detailVC = segue.destination as! PokemonBuilderVC
            detailVC.pokemonName = team[selectedItem].name
            detailVC.pokemonImageName = team[selectedItem].imageID
            detailVC.pokemonManagedObjectID = team[selectedItem].objectID
        }
    }
    

    // MARK: UICollectionViewDataSource

//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return team.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PokemonCollectionCell
    
        // Configure the cell
        cell.setPokemonInfo(for: team[indexPath.row])
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected \(indexPath.item)")
        
//        let pokemonSelected = team[indexPath.row]
//        if let pokemonName = pokemonSelected.name?.formatPokemonName() {
//            let actionSheet = UIAlertController(title: "Remove \(pokemonName)?", message: nil, preferredStyle: .actionSheet)
//            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            actionSheet.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] _ in
//                self?.remove(pokemon: pokemonSelected)
//            }))
//            present(actionSheet, animated: true)
//        }
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension TeamBuilderVC: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        simpleOver.popStyle = (operation == .pop)
        return simpleOver
    }
}
