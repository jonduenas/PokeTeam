//
//  ColorBlockView.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/13/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class ColorBlockView: UIView {
    
    var topColor: UIColor = #colorLiteral(red: 0.9764705882, green: 0.4470588235, blue: 0.2823529412, alpha: 1)
    var bottomColor: UIColor = #colorLiteral(red: 0.9568627451, green: 0.3215686275, blue: 0.231372549, alpha: 1)
    
    var bottomColorLayer: CAShapeLayer!
    var topColorLayer: CAShapeLayer!
    
    private(set) var isAnimating: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createColorBlocks()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        createColorBlocks()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutColorBlocks()
    }
    
    func createColorBlocks() {
        bottomColorLayer = createColorBlockLayer(strokeColor: .clear, fillColor: bottomColor)
        
        self.layer.addSublayer(bottomColorLayer)
        
        topColorLayer = createColorBlockLayer(strokeColor: .clear, fillColor: topColor)

        self.layer.insertSublayer(topColorLayer, above: bottomColorLayer)
    }
    
    func layoutColorBlocks() {
        guard let superview = self.superview else { return }
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.widthAnchor.constraint(equalToConstant: superview.frame.width / 2).isActive = true
        self.heightAnchor.constraint(equalToConstant: superview.frame.height / 2).isActive = true
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.close()

        bottomColorLayer.path = path.cgPath
        
        topColorLayer.path = path.cgPath
        topColorLayer.transform = CATransform3DMakeTranslation(30, 30, 0)
    }
    
    private func createColorBlockLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        layer.fillColor = fillColor.cgColor
        layer.strokeColor = strokeColor.cgColor
        
        return layer
    }
}
