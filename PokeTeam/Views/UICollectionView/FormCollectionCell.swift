//
//  FormCollectionCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 10/22/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class FormCollectionCell: UICollectionViewCell {
    
    let selectedBackgroundColor = #colorLiteral(red: 0.9025042653, green: 0.9025042653, blue: 0.9025042653, alpha: 1)
    var cornerRadius: CGFloat = 5
    
    @IBOutlet weak var formImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = cornerRadius
        
        let backgroundView = UIView(frame: bounds)
        backgroundView.backgroundColor = selectedBackgroundColor
        selectedBackgroundView = backgroundView
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
