//
//  AbilityDetailVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/13/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine
import CoreData

class AbilityDetailVC: UIViewController {
    
    var abilityManagedObjectID: NSManagedObjectID?
    var ability: AbilityMO?
    var abilityData: AbilityData?
    var abilityDescription: String?
    var indicatorView = UIActivityIndicatorView()
    var subscriptions: Set<AnyCancellable> = []

    @IBOutlet weak var abilityHeaderLabel: UILabel!
    @IBOutlet weak var abilityDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let abilityObjectID = abilityManagedObjectID {
            ability = PokemonManager.shared.context.object(with: abilityObjectID) as? AbilityMO
        }
        
        initializeActivityIndicator()
        
        if let abilityMOID = abilityManagedObjectID {
            ability = PokemonManager.shared.context.object(with: abilityMOID) as? AbilityMO
            print(ability!.name!)
        }
        
        if shouldUpdateDetails() {
            print("Fetching ability details")
            fetchAbilityDetails()
        } else {
            print("Ability details already present.")
            showAbilityDetails()
        }
    }
    
    private func initializeActivityIndicator() {
        indicatorView = self.view.activityIndicator(style: .large, frame: self.view.frame, center: CGPoint(x: self.view.frame.width / 2, y: 100))
        view.addSubview(indicatorView)
    }
    
    private func shouldUpdateDetails() -> Bool {
        return ability?.abilityDescription == nil || ability?.abilityDescription == ""
    }
    
    private func fetchAbilityDetails() {
        guard let abilityMOID = abilityManagedObjectID else { return }

        let abilityMO = PokemonManager.shared.backgroundContext.object(with: abilityMOID) as! AbilityMO
        
        guard let abilityURL = URL(string: abilityMO.urlString!) else {
            print("Error creating ability URL")
            return
        }

        setState(loading: true)

        PokemonManager.shared.fetchFromAPI(of: AbilityData.self, from: abilityURL)
            .sink(receiveCompletion: { results in
                switch results {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            },
                  receiveValue: { (abilityData) in
                    PokemonManager.shared.addAbilityDescription(to: abilityMO.objectID, with: abilityData)
                    PokemonManager.shared.saveContext(PokemonManager.shared.backgroundContext)
                    //self.ability = PokemonManager.shared.context.object(with: abilityMOID) as? AbilityMO
                    
                    DispatchQueue.main.async {
                        self.showAbilityDetails()
                        self.setState(loading: false)
                    }
            })
            .store(in: &subscriptions)
    }
    
    private func showAbilityDetails() {
        abilityHeaderLabel.text = ability?.name?.formatAbilityName()
        abilityDescriptionLabel.text = ability?.abilityDescription
    }
    
    private func setState(loading: Bool) {
        if loading {
            indicatorView.startAnimating()
            abilityHeaderLabel.isHidden = true
            abilityDescriptionLabel.isHidden = true
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
