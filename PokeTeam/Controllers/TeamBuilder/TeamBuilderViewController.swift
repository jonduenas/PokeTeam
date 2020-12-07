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
private let detailSegueIdentifier = "detailSegue"

class TeamBuilderViewController: UIViewController {

    let simpleOver = SimpleOver()
    var teamsArray = [TeamMO]()
    var team = [PokemonMO]()
    var coreDataStack: CoreDataStack!
    var dataManager: DataManager!
    
    var dataSource: UICollectionViewDiffableDataSource<Int, PokemonMO>! = nil
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        setupCustomNavController()
        
        loadSavedTeam()
        
//        collectionView.delegate = self
//        collectionView.dataSource = self
        configureCollectionView()
        configureDataSource()
    }
    
    func setupCustomNavController() {
        let customNavVC = navigationController as! CustomNavVC
        navigationItem.title = "TEAM BUILDER"
        
        customNavVC.setupColorBlock(bottomColor: #colorLiteral(red: 0.768627451, green: 0.1568627451, blue: 0.2078431373, alpha: 1), topColor: #colorLiteral(red: 0.8509803922, green: 0.2196078431, blue: 0.2666666667, alpha: 1), fillScreen: true)
    }

    private func loadSavedTeam() {
        print("attempting load of team")
        
        let request: NSFetchRequest<TeamMO> = TeamMO.fetchRequest()
        
        do {
            teamsArray = try coreDataStack.mainContext.fetch(request)
            if teamsArray.count > 0 {
                print("Found \(teamsArray.count) stored teams")
                let firstTeam = teamsArray[0]
                let teamSet = firstTeam.members
                team = teamSet?.array as! [PokemonMO]
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        } catch {
            print("Team fetch failed: \(error)")
        }
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        //collectionView.register(PokemonCollectionCell.self, forCellWithReuseIdentifier: PokemonCollectionCell.reuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, PokemonMO>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, pokemon) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCollectionCell.reuseIdentifier, for: indexPath) as? PokemonCollectionCell else { fatalError("Could not create new cell")}
            
            cell.setPokemonInfo(for: pokemon)
            
            return cell
        })
        
        applySnapshot()
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PokemonMO>()
        
        snapshot.appendSections([1])
        snapshot.appendItems(team)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        loadSavedTeam()
        applySnapshot()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = collectionView.indexPathsForSelectedItems!
        let selectedItem = indexPath[0].row
        
        if segue.identifier == detailSegueIdentifier {
            let detailVC = segue.destination as! PokemonBuilderVC
            detailVC.pokemonName = team[selectedItem].name
            detailVC.pokemonImageName = team[selectedItem].imageID
            detailVC.pokemonManagedObjectID = team[selectedItem].objectID
            detailVC.coreDataStack = coreDataStack
        }
    }
}

//extension TeamBuilderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return team.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PokemonCollectionCell
//
//        // Configure the cell
//        cell.setPokemonInfo(for: team[indexPath.row])
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Selected \(indexPath.item)")
//    }
//}

extension TeamBuilderViewController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        simpleOver.popStyle = (operation == .pop)
        return simpleOver
    }
}
