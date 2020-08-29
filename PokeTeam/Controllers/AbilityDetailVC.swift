//
//  AbilityDetailVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/13/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine

class AbilityDetailVC: UIViewController {
    
    var ability: AbilityMO?
    var abilityData: AbilityData?
    var abilityDescription: String?
    var indicatorView = UIActivityIndicatorView()
    var subscriptions: Set<AnyCancellable> = []

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
//        guard let ability = ability else { return }
//
//        guard let abilityURL = URL(string: ability.urlString!) else {
//            print("Error creating ability URL")
//            return
//        }
//
//        setState(loading: true)
//
//        PokemonManager.shared.fetchFromAPI(of: AbilityData.self, from: abilityURL)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { _ in },
//                  receiveValue: { (abilityData) in
//                    self.ability = PokemonManager.shared.addAbilityDescription(to: ability, with: abilityData)
//                    DispatchQueue.main.async {
//                        self.updateAbilityUI()
//                        self.setState(loading: false)
//                    }
//            })
//            .store(in: &subscriptions)
    }
    
//    private func updateAbilityUI() {
//        guard let ability = ability else { return }
//
//        abilityHeaderLabel.text = ability.name.capitalized
//        abilityDescriptionLabel.text = ability.description
//    }
    
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
