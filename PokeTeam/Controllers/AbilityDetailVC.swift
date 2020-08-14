//
//  AbilityDetailVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/13/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class AbilityDetailVC: UIViewController {
    
    var abilityName: String = ""
    var abilityURL: String = ""
    var abilityData: AbilityData?
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
        setState(loading: true)
        PokemonManager.shared.fetchFromAPI(urlString: abilityURL, decodeTo: AbilityData.self) { (abilityData) in
            DispatchQueue.main.async {
                self.setState(loading: false)
                print("Ability Loaded")
                self.abilityData = abilityData
                self.updateAbilityUI()
            }
        }
    }
    
    private func getLatestFlavorText() -> String? {
        guard let abilityData = abilityData else { return nil }
        
        var englishFlavorTextArray = [String]()
        
        for description in abilityData.flavorTextEntries {
            if description.language == "en" {
                englishFlavorTextArray.append(description.flavorText)
            }
        }
        return englishFlavorTextArray.last
    }
    
    private func updateAbilityUI() {
        guard let abilityData = abilityData else { return }
        
        abilityHeaderLabel.text = abilityData.name.capitalized
        
        if let latestFlavorText = getLatestFlavorText() {
            abilityDescriptionLabel.text = latestFlavorText.replacingOccurrences(of: "\n", with: " ")
        }
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
