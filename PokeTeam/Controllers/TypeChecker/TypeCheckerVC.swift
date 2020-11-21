//
//  TypeCheckerVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/19/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class TypeCheckerVC: UIViewController {

    let reuseIdentifier = "TypeChartCell"
    
    var type1: PokemonType = .none {
        didSet {
            // TODO: - Calculate weaknesses and strengths and update type arrays
        }
    }
    
    var type2: PokemonType = .none {
        didSet {
            // TODO: - Calculate weaknesses and strengths and update type arrays
        }
    }
    
    var typeSuperWeak = [PokemonType]()
    var typeWeak = [PokemonType]()
    var typeNeutral = [PokemonType]()
    var typeResistant = [PokemonType]()
    var typeSuperResistant = [PokemonType]()
    var typeImmune = [PokemonType]()
    
    var typeSections = [[PokemonType]]()
    
    @IBOutlet weak var type1Button: PokemonTypeButton!
    @IBOutlet weak var type2Button: PokemonTypeButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        initializeButtons()
        
        typeSections = [typeSuperWeak, typeWeak, typeNeutral, typeResistant, typeSuperResistant, typeImmune]
    }
    
    private func initializeButtons() {
        type1Button.pokemonType = PokemonType.grass
        type2Button.pokemonType = PokemonType.steel
    }
    
    @IBAction func type1ButtonTapped(_ sender: Any) {
        print("Type 1 Tapped")
    }
    
    @IBAction func type2ButtonTapped(_ sender: Any) {
        print("Type 2 Tapped")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UICollectionView Methods

extension TypeCheckerVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return typeSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return typeSuperWeak.count
        case 1:
            return typeWeak.count
        case 2:
            return typeNeutral.count
        case 3:
            return typeResistant.count
        case 4:
            return typeSuperResistant.count
        case 5 :
            return typeImmune.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(TypeCheckerHeaderView.self)", for: indexPath) as? TypeCheckerHeaderView else { fatalError("Invalid view type") }
            
            // TODO: - Fix Header Text
            let sectionHeader = "Test Header"
            headerView.headerLabel.text = sectionHeader
            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }
    
}
