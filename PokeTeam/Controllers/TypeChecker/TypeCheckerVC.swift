//
//  TypeCheckerVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/19/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class TypeCheckerVC: UIViewController {
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    enum TypeEffectiveness: String, CaseIterable {
        case superWeak = "Super Weak To"
        case weak = "Weak To"
        case normal = "Normal Damage From"
        case resistant = "Resistant To"
        case superResistant = "Super Resistant To"
        case immune = "Immune To"
    }
    
    var dataSource: UICollectionViewDiffableDataSource<TypeEffectiveness, TypeMO>! = nil
    
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
    
    var typeEffectiveness = [TypeEffectiveness: [TypeMO]]()
    var typeSections = [TypeEffectiveness]()
    
    lazy var allTypes = loadTypeDetails()
    
    @IBOutlet weak var type1Button: PokemonTypeButton!
    @IBOutlet weak var type2Button: PokemonTypeButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setNavigationBarColor(to: UIColor.clear, backgroundEffect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        configureCollectionView()
        configureDataSource()
        
        initializeButtons()
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = collectionView.createTwoColumnLayout()
        collectionView.register(TypeCheckerCell.self, forCellWithReuseIdentifier: TypeCheckerCell.reuseIdentifier)
        collectionView.register(TypeCheckerHeaderView.self, forSupplementaryViewOfKind: TypeCheckerVC.sectionHeaderElementKind, withReuseIdentifier: TypeCheckerHeaderView.reuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<TypeEffectiveness, TypeMO>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, pokemonType) -> UICollectionViewCell? in
            
            //let section = TypeEffectiveness.allCases[indexPath.section]
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeCheckerCell.reuseIdentifier, for: indexPath) as? TypeCheckerCell else { fatalError("Could not create new cell")}
            
            cell.pokemonType = pokemonType.name
            
            return cell
        })
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TypeCheckerHeaderView.reuseIdentifier, for: indexPath) as? TypeCheckerHeaderView else { fatalError("Cannot create header view") }
            
            let section = self.typeSections[indexPath.section]
            
            supplementaryView.label.text = section.rawValue
            
            return supplementaryView
        }
        
        applySnapshot()
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<TypeEffectiveness, TypeMO>()
        
        for section in typeSections {
            snapshot.appendSections([section])
            snapshot.appendItems(typeEffectiveness[section] ?? [])
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func initializeButtons() {
        type1Button.pokemonType = PokemonType.none
        type2Button.pokemonType = PokemonType.none
    }
    
    private func loadTypeDetails() -> [TypeMO] {
        if let loadedTypes = dataManager.getFromCoreData(entity: TypeMO.self, sortBy: "name", isAscending: true) as? [TypeMO] {
            return loadedTypes
        } else {
            print("Error loading Type Objects from Core Data")
            return []
        }
    }
    
    private func calculateAndUpdate() {
        typeEffectiveness = [:]
        typeSections = []
        
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
        
        if !typeCalculator.superWeakTo.isEmpty {
            typeEffectiveness[.superWeak] = Array(typeCalculator.superWeakTo).sorted(by: { $0.name! < $1.name! })
            typeSections.append(.superWeak)
        }
        
        if !typeCalculator.weakTo.isEmpty {
            typeEffectiveness[.weak] = Array(typeCalculator.weakTo).sorted(by: { $0.name! < $1.name! })
            typeSections.append(.weak)
        }
        
        if !typeCalculator.normalDamage.isEmpty {
            typeEffectiveness[.normal] = Array(typeCalculator.normalDamage).sorted(by: { $0.name! < $1.name! })
            typeSections.append(.normal)
        }
        
        if !typeCalculator.resistantTo.isEmpty {
            typeEffectiveness[.resistant] = Array(typeCalculator.resistantTo).sorted(by: { $0.name! < $1.name! })
            typeSections.append(.resistant)
        }
        
        if !typeCalculator.superResistantTo.isEmpty {
            typeEffectiveness[.superResistant] = Array(typeCalculator.superResistantTo).sorted(by: { $0.name! < $1.name! })
            typeSections.append(.superResistant)
        }
        
        if !typeCalculator.immuneTo.isEmpty {
            typeEffectiveness[.immune] = Array(typeCalculator.immuneTo).sorted(by: { $0.name! < $1.name! })
            typeSections.append(.immune)
        }
        
        applySnapshot()
    }

    
    @IBAction func type1ButtonTapped(_ sender: Any) {
        print("Type 1 Tapped")
    }
    
    @IBAction func type2ButtonTapped(_ sender: Any) {
        print("Type 2 Tapped")
    }
    
    
    // MARK: - Navigation

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

extension TypeCheckerVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        print(item.name!)
    }
}
