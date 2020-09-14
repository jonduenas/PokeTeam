//
//  StatView.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/17/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class StatView: UIStackView {

    private let maxStatValue: Float = 255
    
    private var statName: UILabel!
    private var statValue: UILabel!
    private var statProgress: UIProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        self.axis = .horizontal
        self.alignment = .center
        self.distribution = .fill
        self.spacing = 5
        
        statName = UILabel()
        statName.font = .systemFont(ofSize: 18)
        statName.textColor = .label
        statName.textAlignment = .center
        statName.widthAnchor.constraint(greaterThanOrEqualToConstant: 35).isActive = true
        self.addArrangedSubview(statName)
        
        statValue = UILabel()
        statValue.font = .systemFont(ofSize: 18)
        statValue.textColor = .label
        statValue.textAlignment = .center
        statValue.widthAnchor.constraint(greaterThanOrEqualToConstant: 35).isActive = true
        self.addArrangedSubview(statValue)
        
        statProgress = UIProgressView(progressViewStyle: .default)
        statProgress.trackTintColor = .systemGray5
        statProgress.progressTintColor = UIColor(named: "poke-blue")
        statProgress.heightAnchor.constraint(equalToConstant: 10).isActive = true
        statProgress.layer.cornerRadius = 5
        statProgress.clipsToBounds = true
        self.addArrangedSubview(statProgress)
    }
    
    func setUp(name: String, value: Float) {
        self.statName.text = name.uppercased()
        self.statValue.text = "\(Int(value))"
        self.statProgress.progress = value / maxStatValue
    }
}
