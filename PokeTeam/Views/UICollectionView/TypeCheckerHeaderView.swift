//
//  TypeCheckerHeaderView.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/20/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class TypeCheckerHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderReuseIdentifier"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        
        let inset: CGFloat = 10
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
}
