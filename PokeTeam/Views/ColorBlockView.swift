//
//  ColorBlockView.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/13/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class ColorBlockView: UIView, CAAnimationDelegate {
    
    var topColor: UIColor = .blue {
        didSet {
            createColorBlocks()
        }
    }
    var bottomColor: UIColor = .black {
        didSet {
            createColorBlocks()
        }
    }
    
    var bottomColorLayer: CAShapeLayer!
    var topColorLayer: CAShapeLayer!
    var fillScreen: Bool = false
    
    var isAnimating: Bool = false
    
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
    
    func commonInit() {
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        createColorBlocks()
        
        // Slow animation for simulator testing
        //layer.speed = 0.1
    }
    
    func createColorBlockLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
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
        
        // Set size of view to full screen
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        
        let path = UIBezierPath()
        
        if fillScreen {
            // Create path for shape layers as triangle filling most of view
            path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.maxX * 1.5, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            path.close()
            
            bottomColorLayer.path = path.cgPath
            topColorLayer.path = path.cgPath
            
            // Offset layers to prepare for animation - Slides in from left
            bottomColorLayer.transform = CATransform3DMakeTranslation(-self.frame.width, 0, 0)
            topColorLayer.transform = CATransform3DMakeTranslation(-self.frame.width, 0, 0)
        } else {
            // Create path for shape layers as triangle filling half of view
            path.move(to: CGPoint(x: bounds.midX, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
            path.close()
            
            bottomColorLayer.path = path.cgPath
            topColorLayer.path = path.cgPath
            
            // Offset layers to prepare for animation - Slides in from right
            bottomColorLayer.transform = CATransform3DMakeTranslation(self.frame.width, 0, 0)
            topColorLayer.transform = CATransform3DMakeTranslation(self.frame.width + 30, 30, 0)
        }
    }
    
    func animateOnShow(completion: (() -> Void)? = nil) {
        let fromValueTop: CATransform3D = topColorLayer.transform
        let toValueTop: CATransform3D
        
        let fromValueBottom: CATransform3D = bottomColorLayer.transform
        let toValueBottom: CATransform3D
        
        if fillScreen {
            toValueTop = CATransform3DMakeTranslation(0, 0, 0)
            toValueBottom = CATransform3DMakeTranslation(40, 0, 0)
        } else {
            toValueTop = CATransform3DMakeTranslation(30, 30, 0)
            toValueBottom = CATransform3DMakeTranslation(0, 0, 0)
        }
        
        isAnimating = true
        
        let displayLink = CADisplayLink(target: self, selector: #selector(animationDidUpdate))
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let basicAnimationTop = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.transform))
        basicAnimationTop.delegate = self
        basicAnimationTop.fromValue = fromValueTop
        basicAnimationTop.toValue = toValueTop
        basicAnimationTop.duration = 0.2
        basicAnimationTop.timingFunction = CAMediaTimingFunction(name: .easeOut)
        basicAnimationTop.fillMode = .forwards
        basicAnimationTop.isRemovedOnCompletion = false
        
        let basicAnimationBottom = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.transform))
        basicAnimationBottom.delegate = self
        basicAnimationBottom.fromValue = fromValueBottom
        basicAnimationBottom.toValue = toValueBottom
        basicAnimationBottom.duration = 0.15
        basicAnimationBottom.timingFunction = CAMediaTimingFunction(name: .easeOut)
        basicAnimationBottom.fillMode = .forwards
        basicAnimationBottom.isRemovedOnCompletion = false
        
        CATransaction.setCompletionBlock {
            displayLink.invalidate()
            self.isAnimating = false
            completion?()
        }
        
        topColorLayer.add(basicAnimationTop, forKey: "animateTopOnShow_\(arc4random())")
        bottomColorLayer.add(basicAnimationBottom, forKey: "animateBottomOnShow_\(arc4random())")
        CATransaction.commit()
    }
    
    @objc func animationDidUpdate(displayLink: CADisplayLink) {
        //gaurd var progress = topColorLayer.presentation()
    }
}
