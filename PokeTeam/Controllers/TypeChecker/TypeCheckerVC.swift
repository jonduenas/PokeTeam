//
//  TypeCheckerVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/19/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class TypeCheckerVC: UIViewController, CoreDataStackClient {
    let coreDataStack: CoreDataStack
    let dataManager: DataManager
    
    required init?(coder: NSCoder, coreDataStack: CoreDataStack, dataManager: DataManager) {
        self.coreDataStack = coreDataStack
        self.dataManager = dataManager
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    enum TypeEffectiveness: String, CaseIterable {
        case superWeak = "Super Weak To (4x Damage)"
        case weak = "Weak To (2x Damage)"
        case normal = "Normal Damage From"
        case resistant = "Resistant To (0.5x Damage)"
        case superResistant = "Super Resistant To (0.25x Damage)"
        case immune = "Immune To (No Damage)"
    }
    
    let typePickerTransitioningDelegate = TypePickerTransitioningDelegate()
    
    var dataSource: UICollectionViewDiffableDataSource<TypeEffectiveness, TypeMO>! = nil
    
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
    
    var allTypes: [TypeMO] = []
    
    @IBOutlet weak var type1Button: PokemonTypeButton!
    @IBOutlet weak var type2Button: PokemonTypeButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setNavigationBarColor(to: UIColor.clear, backgroundEffect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        configureCollectionView()
        configureDataSource()
        
        initializeButtons()
        
        allTypes = loadTypeDetails()
    }
    
    func reloadData() {
        allTypes.removeAll()
        type1 = .none
        type2 = .none
        initializeButtons()
        applySnapshot()
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = collectionView.createTwoColumnLayout()
        collectionView.register(TypeCheckerCell.self, forCellWithReuseIdentifier: TypeCheckerCell.reuseIdentifier)
        collectionView.register(TypeCheckerHeaderView.self, forSupplementaryViewOfKind: TypeCheckerVC.sectionHeaderElementKind, withReuseIdentifier: TypeCheckerHeaderView.reuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<TypeEffectiveness, TypeMO>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, pokemonType) -> UICollectionViewCell? in
            
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
            print("Loaded \(loadedTypes.count) Pokemon types")
            return loadedTypes
        } else {
            print("Error loading Type Objects from Core Data")
            showAlert(message: "Error loading Pokemon types.")
            return []
        }
    }
    
    private func calculateAndUpdate() {
        typeEffectiveness = [:]
        typeSections = []
        
        if type1 != .none {
            let fetchedObjects = dataManager.getFromCoreData(entity: TypeMO.self, predicate: NSPredicate(format: "name == %@", type1.rawValue)) as! [TypeMO]
            if !fetchedObjects.isEmpty {
                type1Object = fetchedObjects[0]
            }
        } else {
            type1Object = nil
        }
        
        if type2 != .none {
            let fetchedObjects = dataManager.getFromCoreData(entity: TypeMO.self, predicate: NSPredicate(format: "name == %@", type2.rawValue)) as! [TypeMO]
            if !fetchedObjects.isEmpty {
                type2Object = fetchedObjects[0]
            }
        } else {
            type2Object = nil
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
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        print("Info tapped")
        showAlert(message: "This tool is for checking a Pokemon's vulnerabilities based on their typing. Select 1 or 2 types to see which move types will be super effective or not very effective against another Pokemon with those types.")
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var allTypesStrings = [String]()
        for type in allTypes {
            if let typeName = type.name {
                allTypesStrings.append(typeName)
            }
        }
        
        allTypesStrings.append("none")
        
        let typePicker = segue.destination as! TypePickerVC
        
        typePicker.allTypes = allTypesStrings
        typePicker.delegate = self
        
        // Sets slide over transition if screen is large enough to accomodate - standard modal presentation if not
        let screenHeight = UIScreen.main.bounds.height
        
        if screenHeight > typePickerTransitioningDelegate.height {
            typePicker.transitioningDelegate = typePickerTransitioningDelegate
            typePicker.modalPresentationStyle = .custom
        }
        
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
