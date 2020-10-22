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
    let pokemonObjectID: NSManagedObjectID
    
    var colorBlockView: ColorBlockView!
    var backgroundDataManager: DataManager!
    var coreDataStack: CoreDataStack!
    var apiService: APIService!
    
    var pokemon: PokemonMO
    var pokemonDetails: PokemonMO?
    var abilityArray: [AbilityMO]?
    var formIndex = 0
    var formImageArray: [String]?
    var subscriptions: Set<AnyCancellable> = []
    var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet var detailView: UIView!
    @IBOutlet var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonFormsStackView: UIStackView!
    
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
        self.pokemonObjectID = pokemonObjectID

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
        return pokemon.flavorText?.isEmpty ?? true
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
            
            guard let pokemonName = self.pokemon.name else {
                print("Pokemon name was nil")
                return
            }
            
            if let updatedPokemon = self.backgroundDataManager.getFromCoreData(entity: PokemonMO.self, predicate: NSPredicate(format: "name == %@", pokemonName)) as? [PokemonMO] {
                if updatedPokemon.count > 0 {
                    self.pokemon = updatedPokemon[0]
                } else {
                    print("Error finding Pokemon to load from Core Data")
                }
            } else {
                print("Error reloading pokemon")
            }
            DispatchQueue.main.async { [weak self] in
                self?.showDetails()
                self?.setState(loading: false)
            }
        }
        .store(in: &subscriptions)
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
        print("Updating UI")
        pokemonNameLabel.text = pokemon.name?.formatPokemonName()
        
        if let pokemonVarieties = pokemon.varieties {
            if pokemonVarieties.count > 0 {
                layoutFormImages()
            }
        }
        
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
        if pokemon.genus == "" {
            pokemonNumberAndGenusLabel.text = "No. \(pokemonIDString) – Genus Unknown"
        } else {
            pokemonNumberAndGenusLabel.text = "No. \(pokemonIDString) – \(pokemon.genus ?? "Genus Unknown")"
        }
        
        pokemonDescriptionLabel.text = "Error finding Pokemon description."
        
        // TODO: Allow selection of specific flavor text
        switch pokemon.generation {
        case "generation-viii":
            // Use Sword flavor text for Gen 8 only since not every pokemon is in Sword/Shield
            if let flavorText = pokemon.flavorText?["sword"] {
                print(flavorText[0])
                pokemonDescriptionLabel.text = flavorText[0]
            }
        case "generation-vii":
            // Use Ultra-Sun flavor text for anything Gen 7
            if let flavorText = pokemon.flavorText?["ultra-sun"] {
                print(flavorText[0])
                pokemonDescriptionLabel.text = flavorText[0]
            }
        default:
            // Default for all other Pokemon is Pokemon X flavor text
            if let flavorText = pokemon.flavorText?["x"] {
                print(flavorText[0])
                pokemonDescriptionLabel.text = flavorText[0]
            }
        }
        
        heightLabel.text = "\(pokemon.height) m"
        weightLabel.text = "\(pokemon.weight) kg"
    }
    
    private func layoutFormImages() {
//        if let altForms = pokemon.altForm {
//            if altForms.count > 0 {
//                let altFormsArray = altForms.array as! [AltFormMO]
//                formImageArray = [String]()
//
//                guard let originalImageID = pokemon.imageID else { return }
//                formImageArray?.append(originalImageID)
//
//                for form in altFormsArray {
//                    guard let formName = form.formName else { return }
//                    let imageName = "\(originalImageID)-" + formName
//
//                    formImageArray?.append(imageName)
//                }
//
//                print(formImageArray)
//            }
//        }
        
        pokemonFormsStackView.isHidden = false
        
        if let altVarieties = pokemon.varieties {
            print(altVarieties)
            if altVarieties.count > 0 {
                let altVarietiesArray = altVarieties.array as! [PokemonMO]
                formImageArray = [String]()
                
                guard let originalImageID = pokemon.imageID else { return }
                formImageArray?.append(originalImageID)
                
                for form in altVarietiesArray {
                    guard let formName = form.name else { return }
                    guard let pokemonBaseName = pokemon.name else { return }
                    let formattedFormName = formName.replacingOccurrences(of: pokemonBaseName, with: originalImageID)
                    
                    formImageArray?.append(formattedFormName)
                }
                
                // Make sure Forms StackView is empty
                if !pokemonFormsStackView.subviews.isEmpty {
                    for view in pokemonFormsStackView.subviews {
                        view.removeFromSuperview()
                    }
                }
                
                for formImageName in formImageArray! {
                    let formImageButton = FormImageButton()
                    formImageButton.backgroundImageName = formImageName
                    
                    pokemonFormsStackView.addArrangedSubview(formImageButton)
                }
            }
        }
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
        
        abilityArray = abilitySet.array as? [AbilityMO]
        abilityArray?.sort(by: { $0.slot < $1.slot })
        
        guard let abilities = abilityArray else { return }
        
        if abilities.isEmpty {
            // If the API has no abilities listed, e.g. currently all of Gen 8
            let notFoundLabel = UILabel()
            
            if pokemon.generation == "generation-viii" {
                notFoundLabel.text = "Abilities currently unknown"
            } else {
                notFoundLabel.text = "Error loading abilities"
            }
            
            abilitiesStackView.addArrangedSubview(notFoundLabel)
        } else {
            for (index, ability) in abilities.enumerated() {
                let abilityButton = AbilityButton()

                if let abilityName = ability.abilityDetails?.name {
                    abilityButton.setTitle(abilityName.formatAbilityName(), for: .normal)
                }

                abilityButton.tag = index
                abilityButton.addTarget(self, action: #selector(abilityButtonTapped), for: .touchUpInside)
                
                abilitiesStackView.addArrangedSubview(abilityButton)
                abilitiesStackView.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func imageLeftButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func imageRightButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func abilityButtonTapped(sender: UIButton!) {
        print(sender.tag)
        guard let abilities = abilityArray else { return }

        let storyboard = UIStoryboard(name: "Pokedex", bundle: nil)
        let abilityController = storyboard.instantiateViewController(withIdentifier: "AbilityVC") as! AbilityDetailVC
        abilityController.abilityName = abilities[sender.tag].abilityDetails?.name
//        abilityController.abilityManagedObjectID = abilities[sender.tag].objectID
//        print(abilities[sender.tag])
        abilityController.coreDataStack = coreDataStack
//        abilityController.backgroundDataManager = backgroundDataManager
//        abilityController.apiService = apiService
        
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
