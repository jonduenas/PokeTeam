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
    
    let largeTitleSize: CGFloat = 34
    let subTitleSize: CGFloat = 25
    let abilityTransitioningDelegate = AbilityTransitioningDelegate()
    let pokemonManagedObjectID: NSManagedObjectID
    
    var colorBlockView: ColorBlockView!
    var backgroundDataManager: DataManager!
    var coreDataStack: CoreDataStack!
    var apiService: APIService!
    
    var pokemon: PokemonMO
    var pokemonDetails: PokemonMO?
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
    
    init?(coder: NSCoder, pokemonObjectID: NSManagedObjectID, coreDataStack: CoreDataStack, dataManager: DataManager, apiService: APIService) {
        self.coreDataStack = coreDataStack
        self.backgroundDataManager = dataManager
        self.apiService = apiService
        self.pokemonManagedObjectID = pokemonObjectID

        pokemon = coreDataStack.mainContext.object(with: pokemonObjectID) as! PokemonMO
        
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
        
        colorBlockView = ColorBlockView()
        colorBlockView.bottomColor = #colorLiteral(red: 0.9568627451, green: 0.3215686275, blue: 0.231372549, alpha: 1)
        colorBlockView.topColor = #colorLiteral(red: 0.9764705882, green: 0.4470588235, blue: 0.2823529412, alpha: 1)
        colorBlockView.fillScreen = false
        view.insertSubview(colorBlockView, at: 0)
        
        if shouldFetchDetails() {
            fetchDetails()
        } else {
            showDetails()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        colorBlockView.animateOnShow()
    }
    
    private func shouldFetchDetails() -> Bool {
        return pokemon.flavorText == "" || pokemon.flavorText == nil
    }
    
    private func showDetails() {
        updatePokemonUI()
        updateStats()
        layoutAbilities()
    }
    
    private func fetchDetails() {
        setState(loading: true)
        
        print("Fetching Pokemon details from API")
        
        var speciesURL: URL? = nil
        pokemon.managedObjectContext?.performAndWait {
            guard let speciesStringURL = pokemon.speciesURL else { return }
            speciesURL = URL(string: speciesStringURL)
        }
        
        apiService.fetch(type: SpeciesData.self, from: speciesURL!)
            .flatMap { speciesData -> AnyPublisher<PokemonData, Error> in
                let updatedPokemon = self.backgroundDataManager.updateDetails(for: self.pokemon.objectID, with: speciesData)
                let pokemonDataURL = URL(string: updatedPokemon.pokemonURL!)
                return self.apiService.fetch(type: PokemonData.self, from: pokemonDataURL!)
        }
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Finished updating Pokemon")
            case .failure(let error):
                print("Error updating Pokemon: \(error) - \(error.localizedDescription)")
            }
        }) { pokemonData in
            self.backgroundDataManager.updateDetails(for: self.pokemon.objectID, with: pokemonData)
            self.coreDataStack.saveContext(self.backgroundDataManager.managedObjectContext)
            //self.reloadPokemon(pokemon: pokemonMO)
            DispatchQueue.main.async { [weak self] in
                self?.showDetails()
                self?.setState(loading: false)
            }
        }
        .store(in: &subscriptions)
    }
    
    func reloadPokemon(pokemon: PokemonMO) {
        guard let pokemonName = pokemon.name else { return }

        let pokemonRequest: NSFetchRequest<PokemonMO> = PokemonMO.fetchRequest()
        pokemonRequest.predicate = NSPredicate(format: "name == %@", pokemonName)
        
        do {
            let pokemonFetched = try backgroundDataManager.managedObjectContext.fetch(pokemonRequest)
            if pokemonFetched.count == 1 {
                self.pokemon = pokemonFetched[0]
            }
        } catch {
            print("Error reloading Pokemon - \(error) - \(error.localizedDescription)")
        }
    }
    
    func fetchPokemonData(with id: Int) -> AnyPublisher<PokemonData, Error> {
        let pokemonURL = apiService.createURL(for: .pokemon, fromIndex: id)!
        
        return apiService.fetch(type: PokemonData.self, from: pokemonURL)
    }
    
    func fetchSpeciesData(with url: String) -> AnyPublisher<SpeciesData, Error> {
        let speciesURL = URL(string: url)!
        
        return apiService.fetch(type: SpeciesData.self, from: speciesURL)
    }
    
    func fetchFormData(with form: NameAndURL) -> AnyPublisher<FormData, Error> {
        let formURL = URL(string: form.url)!
        
        return apiService.fetch(type: FormData.self, from: formURL)
    }
    
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
        pokemonNumberAndGenusLabel.text = "No. \(pokemonIDString) –– \(pokemon.genus ?? "")"
        
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
        abilityArray?.sort(by: { $0.slot < $1.slot })
        
        guard let abilities = abilityArray else { return }
        
        for (index, ability) in abilities.enumerated() {
            let abilityButton = UIButton()

            if let abilityName = ability.name {
                if ability.isHidden {
                    abilityButton.setTitle("\(abilityName.formatAbilityName()) *", for: .normal)
                } else {
                    abilityButton.setTitle(abilityName.formatAbilityName(), for: .normal)
                }
            }

            abilityButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            abilityButton.widthAnchor.constraint(equalToConstant: 175).isActive = true
            abilityButton.backgroundColor = UIColor(named: "poke-blue")
            abilityButton.titleLabel?.textColor = UIColor.white
            abilityButton.layer.cornerRadius = 20
            abilityButton.clipsToBounds = false
            // Shadow
            abilityButton.layer.shadowColor = UIColor.black.cgColor
            abilityButton.layer.shadowOpacity = 0.4
            abilityButton.layer.shadowOffset = CGSize(width: 0, height: 2.5)
            abilityButton.layer.shadowRadius = 2
            
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
        abilityController.abilityManagedObjectID = abilities[sender.tag].objectID
        abilityController.coreDataStack = coreDataStack
        abilityController.backgroundDataManager = backgroundDataManager
        abilityController.apiService = apiService
        
        abilityController.transitioningDelegate = abilityTransitioningDelegate
        abilityController.modalPresentationStyle = .custom

        self.present(abilityController, animated: true)
    }
    
    @objc private func addToTeam() {
        if let existingTeam = loadTeam() {
            let existingTeamArray = existingTeam.members?.array as! [PokemonMO]
            if existingTeamArray.contains(pokemon) {
                showAlert(title: "Error adding to team", message: "This Pokemon is already in your team. Each team member must be a unique species.")
                return
            } else if existingTeamArray.count >= 6 {
                showAlert(title: "Error adding to team", message: "You can only have 6 Pokemon in a team. Please remove one before adding another.")
                return
            } else {
                showAddToTeamAlert(team: existingTeam)
            }
        } else {
            showAddToTeamAlert(team: nil)
        }
        
    }
    
    private func showAddToTeamAlert(team: TeamMO?) {
        let alertController = UIAlertController(title: "Add to team", message: "Would you like to add \(pokemon.name?.formatPokemonName() ?? "this pokemon") to your team?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            if let existingTeam = team {
                existingTeam.addToMembers(self.pokemon)
                print("Adding \(self.pokemon.name!) to existing team.")
                self.coreDataStack.saveContext()
            } else {
                let newTeam = self.backgroundDataManager.addTeam()
                newTeam.addToMembers(self.pokemon)
                print("Adding \(self.pokemon.name!) to new team.")
                self.coreDataStack.saveContext()
            }
        }))
        present(alertController, animated: true)
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
    
    private func loadTeam() -> TeamMO? {
        let context = coreDataStack.mainContext
        let teamRequest: NSFetchRequest<TeamMO> = TeamMO.fetchRequest()
        
        do {
            let teams = try context.fetch(teamRequest)
            if teams.count > 0 {
                return teams[0]
            } else {
                return nil
            }
        } catch {
            print("Error reloading Pokemon - \(error) - \(error.localizedDescription)")
        }
        return nil
    }
}

extension UIViewController {
    func showAlert(title: String = "", message: String, afterConfirm: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let action = afterConfirm {
                action()
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
