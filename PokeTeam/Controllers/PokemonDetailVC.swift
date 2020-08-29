//
//  PokemonDetailVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/3/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine
import CoreData

class PokemonDetailVC: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let largeTitleSize: CGFloat = 34
    let subTitleSize: CGFloat = 25
    let abilityTransitioningDelegate = AbilityTransitioningDelegate()

    let pokemon: PokemonMO
    var pokemonDetails: PokemonMO?
    //lazy var pokemonTeam = PokemonTeam()
    var abilityArray: [AbilityMO]?
    var subscriptions: Set<AnyCancellable> = []
    var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet var detailView: UIView!
    @IBOutlet var pokemonImageView: UIImageView!
    
    @IBOutlet var pokemonNameLabel: UILabel!
    @IBOutlet var pokemonType1Label: PokemonTypeLabel!
    @IBOutlet var pokemonType2Label: PokemonTypeLabel!
    @IBOutlet var pokemonNumberAndGenusLabel: UILabel!
    @IBOutlet var pokemonDescriptionLabel: UILabel!
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
    
    init?(coder: NSCoder, pokemon: PokemonMO) {
        self.pokemon = pokemon

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Pokémon Detail"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToTeam))

        indicatorView = self.view.activityIndicator(style: .large, center: self.view.center)
        view.addSubview(indicatorView)
        
        if shouldFetchDetails() {
            fetchPokemon()
        } else {
            updateDetails()
        }
    }
    
    private func shouldFetchDetails() -> Bool {
        if pokemon.flavorText == "" || pokemon.flavorText == nil {
            return true
        } else {
            return false
        }
    }
    
    private func updateDetails() {
        updatePokemonUI()
        updateStats()
        layoutAbilities()
    }
    
    private func fetchPokemon() {
        guard let pokemonURL = URL(string: pokemon.pokemonURL!) else {
            print("Error creating URL")
            return
        }

        setState(loading: true)

        var pokemonData: PokemonData?

        PokemonManager.shared.fetchFromAPI(of: PokemonData.self, from: pokemonURL)
            .map({ (pokemon) -> String in
                pokemonData = pokemon
                return pokemon.species.url
            })
            .flatMap({ (speciesURL) in
                return self.fetchSpeciesData(for: speciesURL)
            })
            .sink(receiveCompletion: { results in
                switch results {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            },
                  receiveValue: { (speciesData) in
                    PokemonManager.shared.updateDetails(for: self.pokemon, with: pokemonData!, and: speciesData)
                    self.saveToCoreData()
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.updateDetails()
                        self?.setState(loading: false)
                    }
            })
            .store(in: &subscriptions)
    }
    
    private func fetchSpeciesData(for url: String) -> AnyPublisher<SpeciesData, Error> {
        let speciesURL = URL(string: url)!
        return PokemonManager.shared.fetchFromAPI(of: SpeciesData.self, from: speciesURL)
    }
    
    func saveToCoreData() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving: \(error)")
            }
        }
    }
    
//    func loadPokemon() {
//        let request: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
//        
//        let pokemonID = self.pokemon.id
//        request.predicate = NSPredicate(format: "id == %@", pokemonID)
//        
//        do {
//            self.pokemonDetails = try self.context.fetch(request)[0]
//            
//            DispatchQueue.main.async { [weak self] in
//                self?.updatePokemonUI()
//                self?.updateStats()
//                self?.layoutAbilities()
//                
//                self?.setState(loading: false)
//            }
//        } catch {
//            print("Fetch from Core Data failed: \(error)")
//        }
//    }
    
//    private func finishLoadingPokemon(for pokemon: Pokemon) {
//        DispatchQueue.main.async {
//            self.updatePokemonUI(for: pokemon)
//            self.layoutAbilities(for: pokemon)
//            self.updateStats(for: pokemon)
//            self.setState(loading: false)
//        }
//    }
    
    private func updatePokemonUI() {
        pokemonNameLabel.text = pokemon.name?.capitalized
        
        if let imageID = pokemon.imageID {
            pokemonImageView.image = UIImage(named: imageID)
        }
        
        // Update Pokemon types
        if let pokemonType = pokemon.type {
            if pokemonType.count > 1 {
                pokemonType1Label.setType(for: pokemonType[0])
                pokemonType2Label.setType(for: pokemonType[1])
            } else {
                pokemonType1Label.setType(for: pokemonType[0])
                pokemonType2Label.isHidden = true
            }
        }
        
        let pokemonIDString = String(withInt: Int(pokemon.id), leadingZeros: 3)
        pokemonNumberAndGenusLabel.text = "#\(pokemonIDString) –– \(pokemon.genus ?? "")"
        
        pokemonDescriptionLabel.text = pokemon.flavorText
        heightLabel.text = "\(pokemon.height) m"
        weightLabel.text = "\(pokemon.weight) kg"
    }
    
    private func updateStats() {
        let mapping: [(shortName: PokemonStatShortName, fullName: PokemonStatName, statView: StatView)] = [
            (PokemonStatShortName.hp, PokemonStatName.hp, hpStatView),
            (PokemonStatShortName.attack, PokemonStatName.attack, attackStatView),
            (PokemonStatShortName.defense, PokemonStatName.defense, defenseStatView),
            (PokemonStatShortName.specialAttack, PokemonStatName.specialAttack, specialAttackStatView),
            (PokemonStatShortName.specialDefense, PokemonStatName.specialDefense, specialDefenseStatView),
            (PokemonStatShortName.speed, PokemonStatName.speed, speedStatView)
        ]
        
        if let pokemonStats = pokemon.stats {
            for stat in mapping {
                stat.statView.setUp(name: stat.shortName.rawValue, value: pokemonStats[stat.fullName.rawValue]!)
            }
            
            // Total Stats
            var totalStats: Int = 0
            for stat in pokemonStats {
                totalStats += Int(stat.value)
            }
            
            statTotalLabel.text = "TOTAL \(totalStats)"
        }
    }
    
    private func layoutAbilities() {
        guard let abilitySet = pokemon.abilities else { return }
        
        abilityArray = abilitySet.allObjects as? [AbilityMO]
        guard let abilities = abilityArray else { return }
        
        for (index, ability) in abilities.enumerated() {
            let abilityButton = UIButton()

            if let abilityName = ability.name {
                if ability.isHidden {
                    abilityButton.setTitle("\(abilityName.capitalized) *", for: .normal)
                } else {
                    abilityButton.setTitle(abilityName.capitalized, for: .normal)
                }
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
        guard let abilities = abilityArray else { return }

        let storyboard = UIStoryboard(name: "Pokedex", bundle: nil)
        let abilityController = storyboard.instantiateViewController(withIdentifier: "AbilityVC") as! AbilityDetailVC
        abilityController.ability = abilities[sender.tag]
        
        abilityController.transitioningDelegate = abilityTransitioningDelegate
        abilityController.modalPresentationStyle = .custom

        self.present(abilityController, animated: true)
    }
    
    @objc private func addToTeam() {
        //guard let pokemon = pokemon else { return }
        
//        let pokemonTeam = PokemonTeam(context: context)
//        pokemonTeam.name = "Test Team"
//        
//        let pokemonManaged = PokemonManaged(context: context)
//        pokemonManaged.name = pokemon.name
//        pokemonManaged.id = Int64(pokemon.id)
//        pokemonManaged.height = pokemon.height
//        pokemonManaged.weight = pokemon.weight
//        pokemonManaged.genus = pokemon.genus
//        pokemonManaged.flavorText = pokemon.flavorText
//        pokemonManaged.imageID = String(pokemon.id)
//        pokemonManaged.generation = pokemon.generation
//        pokemonManaged.moves = pokemon.moves
//        pokemonManaged.abilities = pokemon.abilities
//        pokemonManaged.stats = [:]
//        pokemonManaged.type = []
//        
//        pokemonManaged.addToTeam(pokemonTeam)
        
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
//        guard let teamBuilderNav = self.tabBarController?.viewControllers?[1] else { return }
//        let teamBuilderVC = teamBuilderNav.children.first as! TeamBuilderVC
//
//        teamBuilderVC.team.append(pokemon)
        
        //let success = pokemonTeam.add(pokemon)
        //print(success)
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
