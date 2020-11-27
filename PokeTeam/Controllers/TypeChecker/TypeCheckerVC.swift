//
//  TypeCheckerVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/19/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine

class TypeCheckerVC: UIViewController {

    let reuseIdentifier = "TypeChartCell"
    var coreDataStack: CoreDataStack!
    var dataManager: DataManager!
    var typeCalculator: TypeCalculator!
    var type1Object: TypeMO?
    var type2Object: TypeMO?
    
    var type1: PokemonType = .none {
        didSet {
            type1Button.pokemonType = type1
            calculateAndUpdate()
        }
    }
    
    var type2: PokemonType = .none {
        didSet {
            type2Button.pokemonType = type2
            calculateAndUpdate()
        }
    }
    
    var subscriptions: Set<AnyCancellable> = []
    
    var allTypes = [TypeMO]()
    
    var typeSuperWeak = [TypeMO]()
    var typeWeak = [TypeMO]()
    var typeNeutral = [TypeMO]()
    var typeResistant = [TypeMO]()
    var typeSuperResistant = [TypeMO]()
    var typeImmune = [TypeMO]()
    
    var typeSections = [[TypeMO]]()
    
    @IBOutlet weak var type1Button: PokemonTypeButton!
    @IBOutlet weak var type2Button: PokemonTypeButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setNavigationBarColor(to: UIColor.clear, backgroundEffect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        initializeButtons()
        
        typeSections = [typeSuperWeak, typeWeak, typeNeutral, typeResistant, typeSuperResistant, typeImmune]
        
        loadTypeDetails()
    }
    
    private func initializeButtons() {
        type1Button.pokemonType = PokemonType.none
        type2Button.pokemonType = PokemonType.none
    }
    
    private func loadTypeDetails() {
        if let loadedTypes = dataManager.getFromCoreData(entity: TypeMO.self, sortBy: "name", isAscending: true) as? [TypeMO] {
            allTypes = loadedTypes
            collectionView.reloadData()
        } else {
            print("Error loading Type Objects from Core Data")
        }
    }
    
    private func calculateAndUpdate() {
        if type1 != .none {
            type1Object = dataManager.getFromCoreData(entity: TypeMO.self, predicate: NSPredicate(format: "name == %@", type1.rawValue))?[0] as? TypeMO
        }
        
        if type2 != .none {
            type2Object = dataManager.getFromCoreData(entity: TypeMO.self, predicate: NSPredicate(format: "name == %@", type2.rawValue))?[0] as? TypeMO
        }
        
        if typeCalculator == nil {
            typeCalculator = TypeCalculator(type1: type1Object, type2: type2Object, allTypes: allTypes)
            typeCalculator.parseDamageRelations()
        } else {
            typeCalculator.type1 = type1Object
            typeCalculator.type2 = type2Object
            typeCalculator.parseDamageRelations()
        }
        
        typeSuperWeak = Array(typeCalculator.superWeakTo).sorted(by: { $0.name! < $1.name! })
        typeWeak = Array(typeCalculator.weakTo).sorted(by: { $0.name! < $1.name! })
        typeNeutral = Array(typeCalculator.normalDamage).sorted(by: { $0.name! < $1.name! })
        typeResistant = Array(typeCalculator.resistantTo).sorted(by: { $0.name! < $1.name! })
        typeSuperResistant = Array(typeCalculator.superResistantTo).sorted(by: { $0.name! < $1.name! })
        typeImmune = Array(typeCalculator.immuneTo).sorted(by: { $0.name! < $1.name! })
        
        collectionView.reloadData()
        
        print("Super Weak To:")
        for type in typeSuperWeak{
            print(type.name!)
        }
        
        print("Weak To:")
        for type in typeWeak {
            print(type.name!)
        }
        
        print("Normal Damage:")
        for type in typeNeutral {
            print(type.name!)
        }
        
        print("Resistant To:")
        for type in typeResistant {
            print(type.name!)
        }
        
        print("Super Resistant To:")
        for type in typeSuperResistant {
            print(type.name!)
        }
        
        print("Immune To:")
        for type in typeImmune {
            print(type.name!)
        }
    }

    
    @IBAction func type1ButtonTapped(_ sender: Any) {
        print("Type 1 Tapped")
    }
    
    @IBAction func type2ButtonTapped(_ sender: Any) {
        print("Type 2 Tapped")
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var allTypesStrings = [String]()
        for type in allTypes {
            if let typeName = type.name {
                allTypesStrings.append(typeName)
            }
        }
        
        let typePicker = segue.destination as! TypePickerVC
        
        typePicker.allTypes = allTypesStrings
        typePicker.delegate = self
        
        let buttonTapped = sender as! PokemonTypeButton
        
        switch buttonTapped.tag {
        case 1, 2:
            typePicker.selectedTypeSlot = buttonTapped.tag
        default:
            return
        }
    }
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
