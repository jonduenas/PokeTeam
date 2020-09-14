//
//  ColorBlockView.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/13/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class ColorBlockView: UIView, CAAnimationDelegate {
    
    var topColor: UIColor = #colorLiteral(red: 0.9764705882, green: 0.4470588235, blue: 0.2823529412, alpha: 1)
    var bottomColor: UIColor = #colorLiteral(red: 0.9568627451, green: 0.3215686275, blue: 0.231372549, alpha: 1)
    
    var bottomColorLayer: CAShapeLayer!
    var topColorLayer: CAShapeLayer!
    
    private(set) var isAnimating: Bool = false
    
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
        
        layoutColorBlocks()
    }
    
    private func commonInit() {
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        createColorBlocks()
    }
    
    private func createColorBlockLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        layer.fillColor = fillColor.cgColor
        layer.strokeColor = strokeColor.cgColor
        
        return layer
    }
    
    func createColorBlocks() {
        bottomColorLayer = createColorBlockLayer(strokeColor: .clear, fillColor: bottomColor)
        
        self.layer.addSublayer(bottomColorLayer)
        
        topColorLayer = createColorBlockLayer(strokeColor: .clear, fillColor: topColor)

        self.layer.insertSublayer(topColorLayer, above: bottomColorLayer)
    }
    
    func layoutColorBlocks() {
        guard let superview = self.superview else { return }
        
        // Set size of view and pin to bottom right of superview
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.widthAnchor.constraint(equalToConstant: superview.frame.width / 2).isActive = true
        self.heightAnchor.constraint(equalToConstant: superview.frame.height / 2).isActive = true
        
        // Create path for shape layers as triangle filling half of view
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.close()

        bottomColorLayer.path = path.cgPath
        topColorLayer.path = path.cgPath
        
        // Offset layers to prepare for animation
        bottomColorLayer.transform = CATransform3DMakeTranslation(self.frame.width, 0, 0)
        topColorLayer.transform = CATransform3DMakeTranslation(self.frame.width + 30, 30, 0)
    }
    
    func animateOnShow() {
        let fromValueTop = topColorLayer.transform
        let toValueTop = CATransform3DMakeTranslation(30, 30, 0)
        
        let fromValueBottom = bottomColorLayer.transform
        let toValueBottom = CATransform3DMakeTranslation(0, 0, 0)
        
        isAnimating = true
        
        let displayLink = CADisplayLink(target: self, selector: #selector(animationDidUpdate))
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let basicAnimationTop = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.transform))
        basicAnimationTop.delegate = self
        basicAnimationTop.fromValue = fromValueTop
        basicAnimationTop.toValue = toValueTop
        basicAnimationTop.duration = 0.1
        basicAnimationTop.beginTime = CACurrentMediaTime() + 0.07
        basicAnimationTop.timingFunction = CAMediaTimingFunction(name: .easeOut)
        basicAnimationTop.fillMode = .forwards
        basicAnimationTop.isRemovedOnCompletion = false
        
        let basicAnimationBottom = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.transform))
        basicAnimationBottom.delegate = self
        basicAnimationBottom.fromValue = fromValueBottom
        basicAnimationBottom.toValue = toValueBottom
        basicAnimationBottom.duration = 0.1
        basicAnimationBottom.timingFunction = CAMediaTimingFunction(name: .easeOut)
        basicAnimationBottom.fillMode = .forwards
        basicAnimationBottom.isRemovedOnCompletion = false
        
        CATransaction.setCompletionBlock {
            displayLink.invalidate()
            self.isAnimating = false
        }
        
        topColorLayer.add(basicAnimationTop, forKey: "animateTopOnShow_\(arc4random())")
        bottomColorLayer.add(basicAnimationBottom, forKey: "animateBottomOnShow_\(arc4random())")
        CATransaction.commit()
    }
    
    @objc func animationDidUpdate(displayLink: CADisplayLink) {
        //gaurd var progress = topColorLayer.presentation()
    }
}
