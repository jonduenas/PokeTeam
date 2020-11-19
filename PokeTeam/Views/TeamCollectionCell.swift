//
//  TeamCollectionCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/16/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class TeamCollectionCell: UICollectionViewCell {
    let cornerRadius: CGFloat = 45
    var teamMembers = [PokemonMO]()
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var teamNameLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.white
        layer.cornerRadius = cornerRadius
        addShadow()
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
    func setTeamInfo(_ team: TeamMO) {
        teamNameLabel.text = team.name ?? "Team"
        
        teamMembers = team.members?.array as! [PokemonMO]
        
        if teamMembers.count > 6 {
            print("Error loading team. The member count is greater than 6.")
            return
        }
        
        //imageCollectionView.reloadData()
    }
    
    private func createPokemonImage(_ imageName: String) -> UIImageView {
        let image = UIImage(named: imageName)
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        imageView.image = image
        
        return imageView
    }
}

extension TeamCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "TeamMemberImage", for: indexPath)
        
        let pokemonImageView = createPokemonImage(teamMembers[indexPath.row].imageID ?? "substitute")
        
        cell.contentView.addSubview(pokemonImageView)
        
        pokemonImageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        pokemonImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        
        return cell
    }
    
    
}
