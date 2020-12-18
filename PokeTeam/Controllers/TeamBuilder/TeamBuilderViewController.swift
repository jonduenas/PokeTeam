//
//  TeamBuilderViewController.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/14/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import CoreData

class TeamBuilderViewController: UIViewController {
    private let detailSegueIdentifier = "detailSegue"
    let simpleOver = SimpleOver()
    var teamsArray = [TeamMO]()
    var team = [PokemonMO]()
    var coreDataStack: CoreDataStack!
    var dataManager: DataManager!
    var fetchedResultsController: NSFetchedResultsController<PokemonMO>! = nil
    
    var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>! = nil
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        setupCustomNavController()
        
        configureFetchedResultsController()
        configureCollectionView()
        configureDataSource()
        
        fetchTeam()
    }
    
    func setupCustomNavController() {
        let customNavVC = navigationController as! CustomNavVC
        navigationItem.title = "TEAM BUILDER"
        
        customNavVC.setupColorBlock(bottomColor: #colorLiteral(red: 0.768627451, green: 0.1568627451, blue: 0.2078431373, alpha: 1), topColor: #colorLiteral(red: 0.8509803922, green: 0.2196078431, blue: 0.2666666667, alpha: 1), fillScreen: true)
    }

    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, objectID) -> UICollectionViewCell? in
            guard let pokemonObject = try? self.coreDataStack.mainContext.existingObject(with: objectID) as? PokemonMO else { fatalError("Managed object not available") }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCollectionCell.reuseIdentifier, for: indexPath) as? PokemonCollectionCell else { fatalError("Could not create new cell")}
            
            cell.pokemon = pokemonObject
            
            return cell
        })
        
        collectionView.dataSource = dataSource
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = collectionView.indexPathsForSelectedItems!
        
        if segue.identifier == detailSegueIdentifier {
            let detailVC = segue.destination as! PokemonBuilderVC
            detailVC.pokemonName = fetchedResultsController.object(at: indexPath[0]).name
            detailVC.pokemonImageName = fetchedResultsController.object(at: indexPath[0]).imageID
            detailVC.pokemonManagedObjectID = fetchedResultsController.object(at: indexPath[0]).objectID
            detailVC.coreDataStack = coreDataStack
        }
    }
}

// MARK: - UINavigationController Transitioning Delegate Methods

extension TeamBuilderViewController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        simpleOver.popStyle = (operation == .pop)
        return simpleOver
    }
}

// MARK: - NSFetchedResultsController Methods

extension TeamBuilderViewController: NSFetchedResultsControllerDelegate {
    private func configureFetchedResultsController() {
        let request: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
        
        let filter = NSPredicate(format: "ANY team.name == %@", "defaultTeam")
        request.predicate = filter
        request.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
    }
    
    private func fetchTeam() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error performing fetch - \(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSource<Int, NSManagedObjectID> else {
            assertionFailure("The data source has not implemented snapshot support while it should")
            return
        }
        
        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        let currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        
        let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
            guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
                return nil
            }
            guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
            return itemIdentifier
        }
        snapshot.reloadItems(reloadIdentifiers)
        
        let shouldAnimate = collectionView.numberOfSections != 0
        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: shouldAnimate)
    }
}

// MARK: - UICollectionView Methods

extension TeamBuilderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let moc = dataManager.managedObjectContext
        
        guard let selectedPokemonObjectID = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let selectedPokemonObject = try? moc.existingObject(with: selectedPokemonObjectID) as? PokemonMO else { return }
        
        let alertContoller = UIAlertController(title: "Remove Pokemon from team?", message: "Would you like to remove \(selectedPokemonObject.name?.formatPokemonName() ?? "this Pokemon") from your team?", preferredStyle: .alert)
        alertContoller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertContoller.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
            if let team = selectedPokemonObject.team {
                moc.perform {
                    selectedPokemonObject.removeFromTeam(team)
                    self.coreDataStack.saveContext(moc)
                }
            }
        }))
        present(alertContoller, animated: true)
    }
}
