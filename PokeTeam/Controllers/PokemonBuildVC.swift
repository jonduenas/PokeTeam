//
//  PokemonBuildVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/10/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import CoreData

class PokemonBuildVC: UIViewController {

    var pokemonName: String?
    var pokemonImageName: String?
    var pokemonManagedObjectID: NSManagedObjectID?
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let name = pokemonName {
            navigationItem.title = name.formatPokemonName().uppercased()
        }
        if let imageName = pokemonImageName {
            pokemonImageView.image = UIImage(named: imageName)
        }
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
