//
//  UIView+RoundedCorners.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/9/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class RoundedCorners: UIView {
    
    let cornerRadius: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        commonInit()
    }
    
    private func commonInit() {
        roundedCorners()
        addShadow()
    }
    
    private func roundedCorners() {
        layer.cornerRadius = cornerRadius
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
