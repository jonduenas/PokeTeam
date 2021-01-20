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
    
    private let reuseIdentifier = "FormCell"
    
    let largeTitleSize: CGFloat = 34
    let subTitleSize: CGFloat = 25
    let abilityTransitioningDelegate = AbilityTransitioningDelegate()
    let pokemonObjectID: NSManagedObjectID
    
    var colorBlockView: ColorBlockView!
    var backgroundDataManager: DataManager!
    var coreDataStack: CoreDataStack!
    var apiService: APIService!
    
    var pokemon: PokemonMO
    var pokemonFormsArray = [PokemonMO]()
    var abilityArray: [AbilityMO]?
    var subscriptions: Set<AnyCancellable> = []
    var indicatorView: UIActivityIndicatorView!
    var refreshButton: UIBarButtonItem?
    var addToTeamButton: UIBarButtonItem?
    var isBaseForm: Bool = true
    
    @IBOutlet weak var formCollectionView: UICollectionView!
    
    @IBOutlet var detailView: UIView!
    @IBOutlet var pokemonImageView: UIImageView!
    
    @IBOutlet var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonVarietyNameLabel: UILabel!
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
        pokemonFormsArray.append(pokemon)
        
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeNavigationBar()
        
        indicatorView = self.view.activityIndicator(style: .large, center: self.view.center)
        view.addSubview(indicatorView)
        
        colorBlockView = ColorBlockView()
        colorBlockView.bottomColor = #colorLiteral(red: 0.9568627451, green: 0.3215686275, blue: 0.231372549, alpha: 1)
        colorBlockView.topColor = #colorLiteral(red: 0.9764705882, green: 0.4470588235, blue: 0.2823529412, alpha: 1)
        colorBlockView.fillScreen = false
        view.insertSubview(colorBlockView, at: 0)
        
        formCollectionView.delegate = self
        formCollectionView.dataSource = self
        
        if shouldFetchDetails(for: pokemonFormsArray[0]) {
            fetchDetails(for: pokemonFormsArray[0], isBaseForm: isBaseForm)
        } else {
            showDetails(with: pokemonFormsArray[0])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        colorBlockView.animateOnShow()
    }
    
    private func initializeNavigationBar() {
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
        addToTeamButton = UIBarButtonItem(title: "+ Team", style: .plain, target: self, action: #selector(addToTeam))
        navigationItem.rightBarButtonItem = addToTeamButton
    }
    
    private func shouldFetchDetails(for pokemonForm: PokemonMO) -> Bool {
        return pokemonForm.stats?.isEmpty ?? true
    }
    
    private func showDetails(with pokemonForm: PokemonMO) {
        updateFormsCollection(with: pokemonForm)
        updatePokemonUI(with: pokemonForm)
        updateStats(with: pokemonForm)
        layoutAbilities(with: pokemonForm)
    }
    
    private func changeShownForm(to pokemonForm: PokemonMO) {
        isBaseForm = !pokemonForm.isAltForm
        pokemon = pokemonForm
        updatePokemonUI(with: pokemonForm)
        updateStats(with: pokemonForm)
        layoutAbilities(with: pokemonForm)
    }
    
    private func fetchDetails(for pokemonForm: PokemonMO, isBaseForm: Bool) {
        setState(loading: true)
        
        print("Fetching Pokemon details from API")
        
        var speciesURL: URL? = nil
        pokemonForm.managedObjectContext?.performAndWait {
            guard let speciesStringURL = pokemonForm.speciesURL else { return }
            speciesURL = URL(string: speciesStringURL)
        }
        
        apiService.fetch(type: SpeciesData.self, from: speciesURL!)
            .flatMap { speciesData -> AnyPublisher<PokemonData, Error> in
                let updatedPokemon = self.backgroundDataManager.updateDetails(for: pokemonForm.objectID, with: speciesData)
                let pokemonDataURL = URL(string: updatedPokemon.pokemonURL!)
                return self.apiService.fetch(type: PokemonData.self, from: pokemonDataURL!)
        }
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Finished updating Pokemon")
            case .failure(let error):
                print("Error updating Pokemon: \(error) - \(error.localizedDescription)")
                self.showError(error)
            }
        }) { pokemonData in
            self.backgroundDataManager.updateDetails(for: pokemonForm.objectID, with: pokemonData)
            self.coreDataStack.saveContext(self.backgroundDataManager.managedObjectContext)
            
            pokemonForm.managedObjectContext?.refresh(pokemonForm, mergeChanges: true)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.navigationItem.rightBarButtonItem = self.addToTeamButton
                
                if isBaseForm {
                    self.pokemonFormsArray = [pokemonForm]
                    self.showDetails(with: pokemonForm)
                } else {
                    self.changeShownForm(to: pokemonForm)
                }
                
                self.setState(loading: false)
            }
        }
        .store(in: &subscriptions)
    }
    
    private func showError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showAlert(message: "Error fetching data from the server: \(error.localizedDescription)")
            self.setState(loading: false)
            self.detailView.isHidden = true
            self.navigationItem.rightBarButtonItem = self.refreshButton
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
    
    private func updateFormsCollection(with baseForm: PokemonMO) {
        if let varieties = baseForm.varieties {
            if varieties.count > 0 {
                print("Found \(varieties.count) varieties")
                let varietiesArray = varieties.array as! [PokemonMO]
                pokemonFormsArray += varietiesArray
                
                formCollectionView.isHidden = false
                formCollectionView.reloadData()
                
                // Select first variety on init
                let selectedIndex = IndexPath(item: 0, section: 0)
                formCollectionView.selectItem(at: selectedIndex, animated: false, scrollPosition: .top)
            } else {
                print("No varieties found")
            }
            
            switch pokemonFormsArray.count {
            case 2...6:
                // Set width to fit amount of cells
                let collectionViewWidth: CGFloat = 60 * CGFloat(pokemonFormsArray.count)
                formCollectionView.widthAnchor.constraint(equalToConstant: collectionViewWidth).isActive = true
            case 7...12:
                // Adjust height for cells more than 6 to add another row
                let collectionViewWidth: CGFloat = 360
                formCollectionView.widthAnchor.constraint(equalToConstant: collectionViewWidth).isActive = true
                formCollectionView.heightAnchor.constraint(equalToConstant: 120).isActive = true
            case 13...18:
                // Adjust height for cells more than 12 to add another row
                let collectionViewWidth: CGFloat = 360
                formCollectionView.widthAnchor.constraint(equalToConstant: collectionViewWidth).isActive = true
                formCollectionView.heightAnchor.constraint(equalToConstant: 180).isActive = true
            default:
                formCollectionView.isHidden = true
            }
        }
    }
    
    private func updatePokemonUI(with pokemonForm: PokemonMO) {
        print("Updating UI")
        
        updateName(with: pokemonForm)
        
        if let imageID = pokemonForm.imageID {
            pokemonImageView.image = UIImage(named: imageID)
        }
        
        updateType(with: pokemonForm)
        
        updateNumberAndGenus(with: pokemonForm)
        
        updateDescription(with: pokemonForm)
        
        heightLabel.text = "\(pokemonForm.height) m"
        weightLabel.text = "\(pokemonForm.weight) kg"
    }
    
    fileprivate func updateName(with pokemonForm: PokemonMO) {
        var pokemonName = "Pokemon"
        
        if let name = pokemonForm.name {
            pokemonName = name
        }
        
        pokemonNameLabel.text = pokemonName.formatPokemonName()
        
        if pokemonForm.name != pokemonForm.varietyName {
            pokemonVarietyNameLabel.isHidden = false
            pokemonVarietyNameLabel.text = pokemonForm.varietyName?.formatVarietyName(speciesName: pokemonName)
        } else {
            pokemonVarietyNameLabel.isHidden = true
        }
    }
    
    fileprivate func updateType(with pokemonForm: PokemonMO) {
        // Update Pokemon types
        if let pokemonType = pokemonForm.type {
            if pokemonType.count > 1 {
                pokemonType1Label.setType(for: pokemonType[0])
                pokemonType2Label.setType(for: pokemonType[1])
            } else {
                pokemonType1Label.setType(for: pokemonType[0])
                pokemonType2Label.isHidden = true
            }
        }
    }
    
    fileprivate func updateNumberAndGenus(with pokemonForm: PokemonMO) {
        let pokemonIDString = String(withInt: Int(pokemonForm.nationalPokedexNumber), leadingZeros: 3)
        if pokemonForm.genus == "" {
            pokemonNumberAndGenusLabel.text = "No. \(pokemonIDString) – Genus Unknown"
        } else {
            pokemonNumberAndGenusLabel.text = "No. \(pokemonIDString) – \(pokemonForm.genus ?? "Genus Unknown")"
        }
    }
    
    fileprivate func updateDescription(with pokemonForm: PokemonMO) {
        pokemonDescriptionLabel.text = "Error finding Pokemon description."
        
        switch pokemonForm.generation {
        case "generation-viii":
            // Use Sword flavor text for Gen 8 only since not every pokemon is in Sword/Shield
            if let flavorText = pokemonForm.flavorText?["sword"] {
                print(flavorText[0])
                pokemonDescriptionLabel.text = flavorText[0]
            }
        case "generation-vii":
            // Use Ultra-Sun flavor text for anything Gen 7
            if let flavorText = pokemonForm.flavorText?["ultra-sun"] {
                print(flavorText[0])
                pokemonDescriptionLabel.text = flavorText[0]
            }
        default:
            // Default for all other Pokemon is Pokemon X flavor text
            if let flavorText = pokemonForm.flavorText?["x"] {
                print(flavorText[0])
                pokemonDescriptionLabel.text = flavorText[0]
            }
        }
    }
    
    private func updateStats(with pokemonForm: PokemonMO) {
        let mapping: [(shortName: PokemonStatShortName, fullName: PokemonStatName, statView: StatView)] = [
            (PokemonStatShortName.hp, PokemonStatName.hp, hpStatView),
            (PokemonStatShortName.attack, PokemonStatName.attack, attackStatView),
            (PokemonStatShortName.defense, PokemonStatName.defense, defenseStatView),
            (PokemonStatShortName.specialAttack, PokemonStatName.specialAttack, specialAttackStatView),
            (PokemonStatShortName.specialDefense, PokemonStatName.specialDefense, specialDefenseStatView),
            (PokemonStatShortName.speed, PokemonStatName.speed, speedStatView)
        ]
        
        if let pokemonStats = pokemonForm.stats {
            if !pokemonStats.isEmpty {
                for stat in mapping {
                    stat.statView.setUp(name: stat.shortName.rawValue, value: pokemonStats[stat.fullName.rawValue] ?? 0)
                }
            }
            
            // Total Stats
            var totalStats: Int = 0
            for stat in pokemonStats {
                totalStats += Int(stat.value)
            }
            
            statTotalLabel.text = "TOTAL \(totalStats)"
        }
    }
    
    private func layoutAbilities(with pokemonForm: PokemonMO) {
        guard let abilitySet = pokemonForm.abilities else { return }
        
        // Set abilityArray to an empty array if it's not currently
        if !(abilityArray?.isEmpty ?? false) {
            abilityArray = [AbilityMO]()
        }
        
        // Clear all current buttons and views
        for view in abilitiesStackView.arrangedSubviews {
            abilitiesStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        abilityArray = abilitySet.array as? [AbilityMO]
        abilityArray?.sort(by: { $0.slot < $1.slot })
        
        guard let abilities = abilityArray else { return }
        
        if abilities.isEmpty {
            // If the API has no abilities listed, such as cases where the data is new and being updated
            let notFoundLabel = UILabel()
            
            if pokemonForm.generation == "generation-viii" {
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
    
    @objc private func refreshButtonTapped() {
        fetchDetails(for: pokemon, isBaseForm: isBaseForm)
    }
    
    @objc private func abilityButtonTapped(sender: UIButton!) {
        print(sender.tag)
        guard let abilities = abilityArray else { return }

        let storyboard = UIStoryboard(name: "Pokedex", bundle: nil)
        let abilityController = storyboard.instantiateViewController(withIdentifier: "AbilityVC") as! AbilityDetailVC
        abilityController.abilityName = abilities[sender.tag].abilityDetails?.name
        abilityController.apiService = apiService
        abilityController.coreDataStack = coreDataStack
        abilityController.backgroundDataManager = backgroundDataManager
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
        let alertController = UIAlertController(title: "Add To Team",
                                                message: "Would you like to add \(pokemon.name?.formatPokemonName() ?? "this pokemon") to your team?",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            if let existingTeam = team {
                self.pokemon.managedObjectContext?.perform {
                    self.pokemon.addToTeam(existingTeam)
                    print("Adding \(self.pokemon.name!) to existing team.")
                    self.coreDataStack.saveContext(self.backgroundDataManager.managedObjectContext)
                }
            } else {
                let newTeam = self.backgroundDataManager.addTeam(name: "defaultTeam")
                
                self.pokemon.managedObjectContext?.perform {
                    self.pokemon.addToTeam(newTeam)
                    print("Adding \(self.pokemon.name!) to new team.")
                    self.coreDataStack.saveContext(self.backgroundDataManager.managedObjectContext)
                }
            }
        }))
        present(alertController, animated: true)
    }
    
    private func setState(loading: Bool) {
        if loading {
            detailView.isHidden = true
            navigationItem.rightBarButtonItem?.isEnabled = false
            indicatorView.startAnimating()
        } else {
            detailView.isHidden = false
            navigationItem.rightBarButtonItem?.isEnabled = true
            indicatorView.stopAnimating()
        }
    }
    
    private func loadTeam() -> TeamMO? {
        if let allTeams = backgroundDataManager.getFromCoreData(entity: TeamMO.self) as? [TeamMO] {
            if !allTeams.isEmpty {
                return allTeams[0]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension PokemonDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonFormsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = formCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FormCollectionCell
        
        if pokemonFormsArray.count > 1 {
            if let imageName = pokemonFormsArray[indexPath.row].imageID {
                cell.setImage(to: imageName)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected \(pokemonFormsArray[indexPath.row].varietyName!)")
        
        let selectedForm = pokemonFormsArray[indexPath.row]
        pokemon = selectedForm
        isBaseForm = indexPath.row == 0
        
        if shouldFetchDetails(for: selectedForm) {
            fetchDetails(for: selectedForm, isBaseForm: isBaseForm)
        } else {
            changeShownForm(to: selectedForm)
        }
    }
}
