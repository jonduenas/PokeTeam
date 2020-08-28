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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //var teamsArray = [PokemonTeam]()
    var team = [Pokemon]()
    
    private var numberOfItemsInRow = 3
    private var minimumSpacing = 5
    private var edgeInsetPadding = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "TEAM BUILDER"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reloadData))
        
        loadSavedTeam()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadSavedTeam()
    }
    
    @objc func reloadData() {
        loadSavedTeam()
    }
    
    private func loadSavedTeam() {
        print("attempting load of team")
//        let pokemonTeam = PokemonTeam(context: context)
        //let request: NSFetchRequest<PokemonTeam> = PokemonTeam.fetchRequest()
        
//        do {
//            let teams = try context.fetch(request)
//            let firstTeam = teams[0]
//            team = firstTeam.pokemon!
//        } catch {
//            print("Team fetch failed: \(error)")
//        }
        
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
        
        let pokemon = team[indexPath.row]
        
        cell.setPokemonInfo(for: pokemon)
    
        return cell
    }
}
