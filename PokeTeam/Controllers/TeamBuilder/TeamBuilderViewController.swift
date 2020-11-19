//
//  TeamBuilderViewController.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/14/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "PokemonCollectionCell"
private let segueIdentifier = "detailSegue"

class TeamBuilderViewController: UIViewController {

    let simpleOver = SimpleOver()
    var teamsArray = [TeamMO]()
    var team = [PokemonMO]()
    var coreDataStack: CoreDataStack!
    var dataManager: DataManager!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
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
            detailVC.coreDataStack = coreDataStack
        }
    }
}

extension TeamBuilderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return team.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PokemonCollectionCell
        
        // Configure the cell
        cell.setPokemonInfo(for: team[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected \(indexPath.item)")
    }
}

extension TeamBuilderViewController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        simpleOver.popStyle = (operation == .pop)
        return simpleOver
    }
}
