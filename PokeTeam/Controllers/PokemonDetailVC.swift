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

    var pokemonData: PokemonData?
    var speciesData: SpeciesData?
    var generationData: GenerationData?
    
    var indicatorView = UIActivityIndicatorView()
    
    @IBOutlet var detailView: UIView!
    @IBOutlet var pokemonImageView: UIImageView!
    
    @IBOutlet var pokemonNameLabel: UILabel!
    @IBOutlet var pokemonType1: PokemonTypeLabel!
    @IBOutlet var pokemonType2: PokemonTypeLabel!
    @IBOutlet var pokemonNumberAndGenusLabel: UILabel!
    @IBOutlet var pokemonDescriptionLabel: UILabel!
    @IBOutlet var pokemonRegionLabel: UILabel!
    
    @IBOutlet var baseStatsHeaderLabel: UILabel!
    @IBOutlet var statTotalLabel: UILabel!
    @IBOutlet var statHPLabel: UILabel!
    @IBOutlet var statHPProgress: UIProgressView!
    @IBOutlet var statAttackLabel: UILabel!
    @IBOutlet var statAttackProgress: UIProgressView!
    @IBOutlet var statDefenseLabel: UILabel!
    @IBOutlet var statDefenseProgress: UIProgressView!
    @IBOutlet var statSpAttackLabel: UILabel!
    @IBOutlet var statSpAttackProgress: UIProgressView!
    @IBOutlet var statSpDefenseLabel: UILabel!
    @IBOutlet var statSpDefenseProgress: UIProgressView!
    @IBOutlet var statSpeedLabel: UILabel!
    @IBOutlet var statSpeedProgress: UIProgressView!
    
    @IBOutlet var abilitiesHeaderLabel: UILabel!
    @IBOutlet weak var abilitiesStackView: UIStackView!
    
    init?(coder: NSCoder, pokemon: PokemonEntry) {
        self.pokemonEntry = pokemon

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Pokémon Detail"

        indicatorView = self.activityIndicator(style: .large, center: self.view.center)
        view.addSubview(indicatorView)
        
        loadPokemonInfo()
        setCustomFonts()
        
    }
    
    private func loadPokemonInfo() {
        let pokemonIndex = pokemonEntry.entryNumber
        
        setState(loading: true)
        
        let group = DispatchGroup()
        
        group.enter()
        PokemonManager.shared.fetchFromAPI(index: pokemonIndex, dataType: .pokemon, decodeTo: PokemonData.self) { (pokemon) in
            self.pokemonData = pokemon
            group.leave()
        }
        
        group.enter()
        PokemonManager.shared.fetchFromAPI(index: pokemonIndex, dataType: .species, decodeTo: SpeciesData.self) { (species) in
            self.speciesData = species
            
            let generationURL = species.generation.url
            
            PokemonManager.shared.fetchFromAPI(urlString: generationURL, decodeTo: GenerationData.self) { (generation) in
                self.generationData = generation
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let _ = self.pokemonData {
                if let _ = self.speciesData {
                    self.updatePokemonUI()
                    self.layoutAbilities()
                    self.updateStats()
                }
            }
            self.setState(loading: false)
        }
    }
    
    private func updatePokemonUI() {
        guard let pokemon = pokemonData else { return }
        guard let species = speciesData else { return }
        guard let generation = generationData else { return }
        
        // Update Pokemon Name
        pokemonNameLabel.text = pokemon.name.capitalized
        
        //Update Image
        pokemonImageView.image = UIImage(named: String(pokemon.id))
        
        // Update Pokemon types
        if pokemon.types.count > 1 {
            let type1 = pokemon.types[0].name
            let type2 = pokemon.types[1].name
            
            pokemonType1.text = type1.capitalized
            pokemonType1.backgroundColor = PokemonTypeLabel.colorDictionary[PokemonType(rawValue: type1) ?? PokemonType.unknown]
            pokemonType2.text = type2.capitalized
            pokemonType2.backgroundColor = PokemonTypeLabel.colorDictionary[PokemonType(rawValue: type2) ?? PokemonType.unknown]
        } else {
            let type1 = pokemon.types[0].name
            pokemonType1.text = type1.capitalized
            pokemonType1.backgroundColor = PokemonTypeLabel.colorDictionary[PokemonType(rawValue: type1) ?? PokemonType.unknown]
            pokemonType2.isHidden = true
        }
        
        // Update Pokemon ID# and Genus text
        let pokemonIDString = String(withInt: pokemon.id, leadingZeros: 3)
        
        var genusText = ""
        for genus in species.genera {
            if genus.language == "en" {
                genusText = genus.genus
            }
        }
        
        pokemonNumberAndGenusLabel.text = "#\(pokemonIDString) –– \(genusText)"
        
        // Update Pokemon Description
        var englishFlavorTextArray = [String]()
        var englishFlavorText = ""
        
        for entry in species.flavorTextEntries {
            if entry.language == "en" {
                englishFlavorTextArray.append(entry.flavorText)
                if let latestEntry = englishFlavorTextArray.last {
                   englishFlavorText = latestEntry
                }
            }
        }
        let formattedText = englishFlavorText.replacingOccurrences(of: "\n", with: " ")
        
        pokemonDescriptionLabel.text = formattedText
        
        // Update Region from Generation
        let regionName = generation.mainRegion.uppercased()
        pokemonRegionLabel.text = "REGION: \(regionName)"
    }
    
    private func setCustomFonts() {
        let largeTitleFont = FontKit.roundedFont(ofSize: largeTitleSize, weight: .bold)
        let subTitleFont = FontKit.roundedFont(ofSize: subTitleSize, weight: .semibold)
        
        pokemonNameLabel.font = largeTitleFont
        baseStatsHeaderLabel.font = subTitleFont
        abilitiesHeaderLabel.font = subTitleFont
    }
    
    private func updateStats() {
        guard let pokemon = pokemonData else { return }
        let maxStat: Float = 255
        
        // Parse individual stats from stats array
        var hpStat = 0
        var attackStat = 0
        var defenseStat = 0
        var specialAttackStat = 0
        var specialDefenseStat = 0
        var speedStat = 0
        
        for stat in pokemon.stats {
            if stat.statName == "hp" {
                hpStat = stat.baseStat
            } else if stat.statName == "attack" {
                attackStat = stat.baseStat
            } else if stat.statName == "defense" {
                defenseStat = stat.baseStat
            } else if stat.statName == "special-attack" {
                specialAttackStat = stat.baseStat
            } else if stat.statName == "special-defense" {
                specialDefenseStat = stat.baseStat
            } else if stat.statName == "speed" {
                speedStat = stat.baseStat
            }
        }
        
        // Update UI
        
        // HP
        statHPLabel.text = "\(hpStat)"
        statHPProgress.progress = Float(hpStat) / maxStat
        
        // Attack
        statAttackLabel.text = "\(attackStat)"
        statAttackProgress.progress = Float(attackStat) / maxStat
        
        // Defense
        statDefenseLabel.text = "\(defenseStat)"
        statDefenseProgress.progress = Float(defenseStat) / maxStat
        
        // Special Attack
        statSpAttackLabel.text = "\(specialAttackStat)"
        statSpAttackProgress.progress = Float(specialAttackStat) / maxStat
        
        // Special Defense
        statSpDefenseLabel.text = "\(specialDefenseStat)"
        statSpDefenseProgress.progress = Float(specialDefenseStat) / maxStat
        
        // Speed
        statSpeedLabel.text = "\(speedStat)"
        statSpeedProgress.progress = Float(speedStat) / maxStat
        
        // Total Stats
        let totalStats: Int = Int(hpStat + attackStat + defenseStat + specialAttackStat + specialDefenseStat + speedStat)
        statTotalLabel.text = "TOTAL \(totalStats)"
    }
    
    private func layoutAbilities() {
        guard let pokemonData = pokemonData else { return }
        
        for (index, ability) in pokemonData.abilities.enumerated() {
            let abilityButton = UIButton()
            
            if ability.isHidden {
                abilityButton.setTitle("\(ability.name.capitalized) *", for: .normal)
            } else {
                abilityButton.setTitle(ability.name.capitalized, for: .normal)
            }
            
            abilityButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            abilityButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
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
        print(sender.tag)
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
    
    private func activityIndicator(style: UIActivityIndicatorView.Style = .medium, frame: CGRect? = nil, center: CGPoint? = nil) -> UIActivityIndicatorView {
        let activityViewIndicator = UIActivityIndicatorView(style: style)
        
        if let frame = frame {
            activityViewIndicator.frame = frame
        }
        
        if let center = center {
            activityViewIndicator.center = center
        }
        
        return activityViewIndicator
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
