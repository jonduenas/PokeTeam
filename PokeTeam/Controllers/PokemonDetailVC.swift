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
    let pokemon: Pokemon
    
    @IBOutlet var pokemonImageView: UIImageView!
    
    @IBOutlet var pokemonNameLabel: UILabel!
    @IBOutlet var pokemonType1: UILabel!
    @IBOutlet var pokemonType2: UILabel!
    @IBOutlet var pokemonNumberAndGenusLabel: UILabel!
    @IBOutlet var pokemonDescriptionLabel: UILabel!
    
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
    
    init?(coder: NSCoder, pokemon: Pokemon) {
        self.pokemon = pokemon

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPokemonInfo()
        setCustomFonts()
        layoutAbilities()
    }
    
    private func loadPokemonInfo() {
        let pokemonIndex = pokemon.entryNumber

        PokemonManager.shared.fetchFromAPI(index: pokemonIndex, dataType: .pokemon, decodeTo: PokemonData.self) { (pokemon) in
            PokemonManager.shared.fetchFromAPI(index: pokemonIndex, dataType: .species, decodeTo: SpeciesData.self) { (species) in
                DispatchQueue.main.async {
                    self.updatePokemonUI(with: pokemon, species: species)
                }
            }
        }
    }
    
    private func updatePokemonUI(with pokemon: PokemonData, species: SpeciesData) {
        // Update Pokemon Name
        pokemonNameLabel.text = pokemon.name.capitalized
        
        // Update Pokemon types
        if pokemon.types.count > 1 {
            let type1 = pokemon.types[0].name
            let type2 = pokemon.types[1].name
            
            pokemonType1.text = type1.capitalized
            pokemonType1.backgroundColor = PokemonManager.shared.colorDictionary[PokemonType(rawValue: type1)!]
            print(PokemonType(rawValue: type1)!)
            pokemonType2.text = type2.capitalized
            pokemonType2.backgroundColor = PokemonManager.shared.colorDictionary[PokemonType(rawValue: type2)!]
        } else {
            let type1 = pokemon.types[0].name
            pokemonType1.text = type1.capitalized
            pokemonType1.backgroundColor = PokemonManager.shared.colorDictionary[PokemonType(rawValue: type1)!]
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
