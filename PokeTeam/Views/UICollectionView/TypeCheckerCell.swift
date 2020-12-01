//
//  TypeCheckerCell.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/30/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class TypeCheckerCell: UICollectionViewCell {
    static let reuseIdentifier = "TypeCheckerCellReuseIdentifier"
    
    let cornerRadius: CGFloat = 10
    let typeLabel = UILabel()
    let contentContainer = UIView()
    
    var pokemonType: String? {
        didSet {
            configure()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentContainer)
        
        typeLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        typeLabel.textColor = .white
        typeLabel.addShadow(radius: 0.5)
        
        typeLabel.text = pokemonType?.capitalized
        contentContainer.backgroundColor = UIColor(named: pokemonType ?? "none")
        
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(typeLabel)
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            typeLabel.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
            typeLabel.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor)
        ])
        
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}
