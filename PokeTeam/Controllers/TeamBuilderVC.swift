//
//  TeamBuilderVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/22/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PokemonCollectionCell"

class TeamBuilderVC: UICollectionViewController {
    
    var pokemonTeam = PokemonTeam()
    var team = [Pokemon]()
    
    private var numberOfItemsInRow = 3
    private var minimumSpacing = 5
    private var edgeInsetPadding = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "TEAM BUILDER"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reloadData))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadData()
    }
    
    @objc func reloadData() {
        collectionView.reloadData()
        print("reload")
    }

    // MARK: UICollectionViewDataSource
    
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
