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
    
    init?(coder: NSCoder, pokemon: PokemonEntry) {
        self.pokemonEntry = pokemon

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        indicatorView = self.activityIndicator(style: .large, center: self.view.center)
        view.addSubview(indicatorView)
        
        loadPokemonInfo()
        setCustomFonts()
        layoutAbilities()
    }
    
    private func loadPokemonInfo() {
        let pokemonIndex = pokemonEntry.entryNumber
        
        var pokemonData: PokemonData?
        var speciesData: SpeciesData?

        setState(loading: true)
        
        let group = DispatchGroup()
        
        group.enter()
        PokemonManager.shared.fetchFromAPI(index: pokemonIndex, dataType: .pokemon, decodeTo: PokemonData.self) { (pokemon) in
            pokemonData = pokemon
            group.leave()
        }
        
        group.enter()
        PokemonManager.shared.fetchFromAPI(index: pokemonIndex, dataType: .species, decodeTo: SpeciesData.self) { (species) in
            speciesData = species
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let pokemonData = pokemonData {
                if let speciesData = speciesData {
                    self.updatePokemonUI(with: pokemonData, species: speciesData)
                }
            }
            self.setState(loading: false)
        }
    }
    
    private func updatePokemonUI(with pokemon: PokemonData, species: SpeciesData) {
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
    }
    
    private func setCustomFonts() {
        let largeTitleFont = FontKit.roundedFont(ofSize: largeTitleSize, weight: .bold)
        let subTitleFont = FontKit.roundedFont(ofSize: subTitleSize, weight: .semibold)
        
        pokemonNameLabel.font = largeTitleFont
        baseStatsHeaderLabel.font = subTitleFont
        abilitiesHeaderLabel.font = subTitleFont
    }
    
    private func setStats() {
        
    }
    
    private func layoutAbilities() {
        
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
