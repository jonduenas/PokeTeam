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
        collectionView.backgroundColor = .clear
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, objectID) -> UICollectionViewCell? in
            guard let pokemonObject = try? self.coreDataStack.mainContext.existingObject(with: objectID) as? PokemonMO else { fatalError("Managed object not available") }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCollectionCell.reuseIdentifier, for: indexPath) as? PokemonCollectionCell else { fatalError("Could not create new cell")}
            
            cell.setPokemonInfo(for: pokemonObject)
            
            return cell
        })
        
        collectionView.dataSource = dataSource
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = collectionView.indexPathsForSelectedItems!
        //let selectedItem = indexPath[0].row
        
        if segue.identifier == detailSegueIdentifier {
            let detailVC = segue.destination as! PokemonBuilderVC
            detailVC.pokemonName = fetchedResultsController.object(at: indexPath[0]).name
            detailVC.pokemonImageName = fetchedResultsController.object(at: indexPath[0]).imageID
            detailVC.pokemonManagedObjectID = fetchedResultsController.object(at: indexPath[0]).objectID
            detailVC.coreDataStack = coreDataStack
        }
    }
}

extension TeamBuilderViewController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        simpleOver.popStyle = (operation == .pop)
        return simpleOver
    }
}

extension TeamBuilderViewController: NSFetchedResultsControllerDelegate {
    private func configureFetchedResultsController() {
        let request: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
        
        let filter = NSPredicate(format: "ANY team != nil")
        request.predicate = filter
        
        let sort = NSSortDescriptor(key: "id", ascending: true)
        
        request.sortDescriptors = [sort]
        
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
