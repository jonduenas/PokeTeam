//
//  TeamBuilderVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/22/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PokemonCollectionCell"

class PokemonTeamVC: UICollectionViewController {
    
    var pokemonTeam = PokemonTeam()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "TEAM BUILDER"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reloadData))
        // Register cell classes
//        self.collectionView!.register(PokemonCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadData()
    }
    
    @objc func reloadData() {
        collectionView.reloadData()
        print("reload")
    }

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonTeam.team.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PokemonCollectionCell else { fatalError("Unable to dequeue PokemonCollectionCell") }
        
        let pokemonName = pokemonTeam.team[indexPath.row].name
        
        cell.pokemonNameLabel.text = pokemonName.capitalized
        cell.pokemonImageView.image = UIImage(named: pokemonName)
    
        return cell
    }

    // MARK: UICollectionViewDelegate
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
