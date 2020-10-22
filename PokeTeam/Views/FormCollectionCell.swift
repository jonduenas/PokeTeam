//
//  FormCollectionCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 10/22/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class FormCollectionCell: UICollectionViewCell {
    
    let selectedBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var cornerRadius: CGFloat = 5
    
    @IBOutlet weak var formImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = cornerRadius
        
        if isSelected {
            backgroundColor = selectedBackgroundColor
        }
    }
    
    func setImage(to imageName: String) {
        if let image = UIImage(named: imageName) {
            formImageView.image = image
        } else {
            print("Error finding image with name: \(imageName). Replacing with Substitute.")
            formImageView.image = UIImage(named: "substitute")
        }
    }
}
