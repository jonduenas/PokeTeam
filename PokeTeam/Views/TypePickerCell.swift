//
//  TypePickerCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/27/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class TypePickerCell: UICollectionViewCell {
    let cornerRadius: CGFloat = 10
    
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = cornerRadius
    }
    
    func setTypeInfo(to type: String) {
        typeLabel.text = type.capitalized
        backgroundColor = UIColor(named: type)
    }
}
