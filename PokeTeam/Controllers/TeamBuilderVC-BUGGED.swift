//
//  TeamBuilderVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/22/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "PokemonCollectionCell"

class TeamBuilderVC: UICollectionViewController {
    
    var teamsArray = [TeamMO]()
    var team = [PokemonMO]()
    
    private var numberOfItemsInRow = 3
    private var minimumSpacing = 5
    private var edgeInsetPadding = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "TEAM BUILDER"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reloadData))
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
        self.collectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadSavedTeam()
    }
    
    @objc func reloadData() {
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
                team = teamSet?.allObjects as! [PokemonMO]
            }
        } catch {
            print("Team fetch failed: \(error)")
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 //teamsArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return team.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PokemonCollectionCell else { fatalError("Unable to dequeue PokemonCollectionCell") }
        
        let pokemonObjectID = team[indexPath.row].objectID
        
        cell.setPokemonInfo(for: pokemonObjectID)
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected")
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
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Deselected")
    }
    
    private func remove(pokemon: PokemonMO) {
        PokemonManager.shared.context.performAndWait {
            let team = teamsArray[0]
            team.removeFromMembers(pokemon)
            do {
                try PokemonManager.shared.context.save()
            } catch {
                print(error)
            }
            collectionView.reloadData()
        }
        
    }
}
