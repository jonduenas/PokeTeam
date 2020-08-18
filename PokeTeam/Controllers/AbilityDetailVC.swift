//
//  AbilityDetailVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/13/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class AbilityDetailVC: UIViewController {
    
    var ability: PokemonAbility?
    var abilityData: AbilityData?
    var abilityDescription: String?
    var indicatorView = UIActivityIndicatorView()

    @IBOutlet weak var abilityHeaderLabel: UILabel!
    @IBOutlet weak var abilityDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeActivityIndicator()
        loadAbility()
    }
    
    private func initializeActivityIndicator() {
        indicatorView = self.view.activityIndicator(style: .large, frame: self.view.frame, center: CGPoint(x: self.view.frame.width / 2, y: 100))
        view.addSubview(indicatorView)
    }
    
    private func loadAbility() {
        guard let ability = ability else { return }
        
        guard let abilityURL = URL(string: ability.urlString) else {
            print("Error creating ability URL")
            return
        }
        
        setState(loading: true)
        
        PokemonManager.shared.fetchFromAPI(of: AbilityData.self, from: abilityURL) { (result) in
            switch result {
            case .failure(let error):
                if error is DataError {
                    print(error)
                } else {
                    print(error.localizedDescription)
                }
                print(error.localizedDescription)
            case.success(let abilityData):
                //self.abilityData = abilityData
                self.ability = PokemonManager.shared.addAbilityDescription(to: ability, with: abilityData)
                DispatchQueue.main.async {
                    self.updateAbilityUI()
                    self.setState(loading: false)
                }
            }
        }
    }
    
//        PokemonManager.shared.fetchFromAPI(urlString: ability.urlString, decodeTo: AbilityData.self) { (abilityData) in
//            self.ability = PokemonManager.shared.parseAbilityData(data: abilityData, ability: ability)
//
//            DispatchQueue.main.async {
//                self.setState(loading: false)
//                print("Ability Loaded")
//
//                self.updateAbilityUI()
//            }
//        }
//    }
    
    private func updateAbilityUI() {
        guard let ability = ability else { return }
        
        abilityHeaderLabel.text = ability.name.capitalized
        abilityDescriptionLabel.text = ability.description
    }
    
    private func setState(loading: Bool) {
        if loading {
            indicatorView.startAnimating()
        } else {
            indicatorView.stopAnimating()
            abilityHeaderLabel.isHidden = false
            abilityDescriptionLabel.isHidden = false
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
