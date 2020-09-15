//
//  PokemonBuilderVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/10/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import CoreData

class PokemonBuilderVC: UIViewController {

    var pokemonName: String?
    var pokemonImageName: String?
    var pokemonManagedObjectID: NSManagedObjectID?
    var pokemon: PokemonMO?
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pokemonID = pokemonManagedObjectID {
            pokemon = PokemonManager.shared.context.object(with: pokemonID) as? PokemonMO
        }
        
        if let name = pokemonName {
            navigationItem.title = name.formatPokemonName().uppercased()
        }
        if let imageName = pokemonImageName {
            pokemonImageView.image = UIImage(named: imageName)
        }
    }
    
    @IBAction func trashTapped(_ sender: UIBarButtonItem) {
        let alertContoller = UIAlertController(title: "Remove Pokemon from team?", message: "Are you sure you want to remove \(pokemonName?.formatPokemonName() ?? "this Pokemon") from your team?", preferredStyle: .alert)
        alertContoller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertContoller.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
            guard let pokemon = self.pokemon else { return }
            self.remove(pokemon: pokemon)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alertContoller, animated: true)
    }
    
    private func remove(pokemon: PokemonMO) {
        PokemonManager.shared.context.performAndWait {
            let teamSet = pokemon.team
            let teamArray = teamSet?.allObjects as? [TeamMO]
            if teamArray?.count == 1 {
                if let team = teamArray?[0] {
                    team.removeFromMembers(pokemon)
                }
            }
            
            do {
                try PokemonManager.shared.context.save()
            } catch {
                print(error)
            }
        }
    }
}
