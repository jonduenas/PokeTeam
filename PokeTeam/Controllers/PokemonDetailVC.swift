//
//  PokemonDetailVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/3/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class PokemonDetailVC: UIViewController {

    let largeTitleSize: CGFloat = 34
    let subTitleSize: CGFloat = 25
    let pokemonEntry: PokemonEntry
    
    let abilityTransitioningDelegate = AbilityTransitioningDelegate()

    var pokemon: Pokemon?
    var pokemonData: PokemonData?
    var speciesData: SpeciesData?
    
    var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet var detailView: UIView!
    @IBOutlet var pokemonImageView: UIImageView!
    
    @IBOutlet var pokemonNameLabel: UILabel!
    @IBOutlet var pokemonType1Label: PokemonTypeLabel!
    @IBOutlet var pokemonType2Label: PokemonTypeLabel!
    @IBOutlet var pokemonNumberAndGenusLabel: UILabel!
    @IBOutlet var pokemonDescriptionLabel: UILabel!
    @IBOutlet var pokemonGenerationLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet var baseStatsHeaderLabel: UILabel!
    @IBOutlet var statTotalLabel: UILabel!
    @IBOutlet weak var hpStatView: StatView!
    @IBOutlet weak var attackStatView: StatView!
    @IBOutlet weak var defenseStatView: StatView!
    @IBOutlet weak var specialAttackStatView: StatView!
    @IBOutlet weak var specialDefenseStatView: StatView!
    @IBOutlet weak var speedStatView: StatView!
    
    @IBOutlet var abilitiesHeaderLabel: UILabel!
    @IBOutlet weak var abilitiesStackView: UIStackView!
    
    init?(coder: NSCoder, pokemonEntry: PokemonEntry) {
        self.pokemonEntry = pokemonEntry

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Pokémon Detail"

        indicatorView = self.view.activityIndicator(style: .large, center: self.view.center)
        view.addSubview(indicatorView)
        
        loadPokemonInfo()
    }
    
    private func loadPokemonInfo() {
        guard let url = URL(string: pokemonEntry.url) else {
            print("Error creating URL")
            return
        }
        
        setState(loading: true)
        
        let operationQueue = OperationQueue()
        
        let fetchSpeciesData = BlockOperation {
            let group = DispatchGroup()
            
            group.enter()
            PokemonManager.shared.fetchFromAPI(of: SpeciesData.self, from: url) { (result) in
                switch result {
                case .failure(let error):
                    if error is DataError {
                        print(error)
                        operationQueue.cancelAllOperations()
                    } else {
                        print(error.localizedDescription)
                        operationQueue.cancelAllOperations()
                    }
                case.success(let speciesData):
                    self.speciesData = speciesData
                    group.leave()
                }
            }
            group.wait()
        }
        operationQueue.addOperation(fetchSpeciesData)
        
        let fetchPokemonData = BlockOperation {
            let group = DispatchGroup()
            
            guard let pokemonURL = PokemonManager.shared.createURL(for: .pokemon, fromIndex: self.speciesData!.id) else {
                print("Error creating URL from speciesData")
                return
            }
            
            group.enter()
            PokemonManager.shared.fetchFromAPI(of: PokemonData.self, from: pokemonURL) { (result) in
                switch result {
                case .failure(let error):
                    if error is DataError {
                        print(error)
                    } else {
                        print(error.localizedDescription)
                    }
                case.success(let pokemonData):
                    self.pokemonData = pokemonData
                    group.leave()
                }
            }
            group.wait()
        }
        fetchPokemonData.addDependency(fetchSpeciesData)
        operationQueue.addOperation(fetchPokemonData)
        
        let parseData = BlockOperation {
            self.pokemon = PokemonManager.shared.parsePokemonData(pokemonData: self.pokemonData!, speciesData: self.speciesData!)
        }
        parseData.addDependency(fetchSpeciesData)
        parseData.addDependency(fetchPokemonData)
        operationQueue.addOperation(parseData)
        
        let finishUpdating = BlockOperation {
            DispatchQueue.main.async {
                self.updatePokemonUI()
                self.layoutAbilities()
                self.updateStats()
                self.setState(loading: false)
            }
        }
        finishUpdating.addDependency(parseData)
        operationQueue.addOperation(finishUpdating)
    }
    
    private func updatePokemonUI() {
        guard let pokemon = pokemon else { return }
        
        // Update Pokemon Name
        pokemonNameLabel.text = pokemon.name.capitalized
        
        //Update Image
        pokemonImageView.image = UIImage(named: pokemon.imageID)
        
        // Update Pokemon types
        if pokemon.type.count > 1 {
            let type1 = pokemon.type[0]
            let type2 = pokemon.type[1]
            
            pokemonType1Label.text = type1.rawValue.capitalized
            pokemonType1Label.backgroundColor = PokemonTypeLabel.colorDictionary[type1]
            
            pokemonType2Label.text = type2.rawValue.capitalized
            pokemonType2Label.backgroundColor = PokemonTypeLabel.colorDictionary[type2]
        } else {
            let type1 = pokemon.type[0]
            
            pokemonType1Label.text = type1.rawValue.capitalized
            pokemonType1Label.backgroundColor = PokemonTypeLabel.colorDictionary[type1]
            
            pokemonType2Label.isHidden = true
        }
        
        // Update Pokemon ID# and Genus text
        let pokemonIDString = String(withInt: pokemon.id, leadingZeros: 3)
        
        pokemonNumberAndGenusLabel.text = "#\(pokemonIDString) –– \(pokemon.genus)"
        
        // Update Pokemon Description
        pokemonDescriptionLabel.text = pokemon.description
        
        // Update Generation
        pokemonGenerationLabel.text = pokemon.generation
        
        // Update height and weight
        heightLabel.text = "\(pokemon.height) m"
        weightLabel.text = "\(pokemon.weight) kg"
    }
    
    private func updateStats() {
        guard let pokemon = pokemon else { return }
        
        let mapping: [(shortName: PokemonStatShortName, fullName: PokemonStatName, statView: StatView)] = [
            (PokemonStatShortName.hp, PokemonStatName.hp, hpStatView),
            (PokemonStatShortName.attack, PokemonStatName.attack, attackStatView),
            (PokemonStatShortName.defense, PokemonStatName.defense, defenseStatView),
            (PokemonStatShortName.specialAttack, PokemonStatName.specialAttack, specialAttackStatView),
            (PokemonStatShortName.specialDefense, PokemonStatName.specialDefense, specialDefenseStatView),
            (PokemonStatShortName.speed, PokemonStatName.speed, speedStatView)
        ]
        
        for stat in mapping {
            stat.statView.setUp(name: stat.shortName.rawValue, value: pokemon.stats[stat.fullName]!)
        }
        
        // Total Stats
        var totalStats: Int = 0
        for stat in pokemon.stats {
            totalStats += Int(stat.value)
        }
        
        statTotalLabel.text = "TOTAL \(totalStats)"
    }
    
    private func layoutAbilities() {
        guard let abilities = pokemon?.abilities else { return }
        
        for (index, ability) in abilities.enumerated() {
            let abilityButton = UIButton()

            if ability.isHidden {
                abilityButton.setTitle("\(ability.name.capitalized) *", for: .normal)
            } else {
                abilityButton.setTitle(ability.name.capitalized, for: .normal)
            }

            abilityButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            abilityButton.widthAnchor.constraint(equalToConstant: 175).isActive = true
            abilityButton.backgroundColor = UIColor(named: "poke-blue")
            abilityButton.titleLabel?.textColor = UIColor.white
            abilityButton.layer.cornerRadius = 20
            abilityButton.tag = index
            abilityButton.addTarget(self, action: #selector(abilityButtonTapped), for: .touchUpInside)
            abilitiesStackView.addArrangedSubview(abilityButton)
            abilitiesStackView.translatesAutoresizingMaskIntoConstraints = false
        }

        let hiddenLabel = UILabel()
        hiddenLabel.text = "* Hidden Ability"
        hiddenLabel.font = UIFont.systemFont(ofSize: 12)
        abilitiesStackView.addArrangedSubview(hiddenLabel)
    }
    
    @objc private func abilityButtonTapped(sender: UIButton!) {
        guard let abilities = pokemon?.abilities else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let abilityController = storyboard.instantiateViewController(withIdentifier: "AbilityVC") as! AbilityDetailVC
        abilityController.ability = abilities[sender.tag]
        
        abilityController.transitioningDelegate = abilityTransitioningDelegate
        abilityController.modalPresentationStyle = .custom

        self.present(abilityController, animated: true)
    }
    
    private func setState(loading: Bool) {
        if loading {
            detailView.isHidden = true
            indicatorView.startAnimating()
        } else {
            detailView.isHidden = false
            indicatorView.stopAnimating()
        }
    }
}

extension String {
    init(withInt int: Int, leadingZeros: Int = 1) {
        self.init(format: "%0\(leadingZeros)d", int)
    }

    func leadingZeros(_ zeros: Int) -> String {
        if let int = Int(self) {
            return String(withInt: int, leadingZeros: zeros)
        }
        print("Warning: \(self) is not an Int")
        return ""
    }
}
