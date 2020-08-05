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
    @IBOutlet var pokemonNumberLabel: UILabel!
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
