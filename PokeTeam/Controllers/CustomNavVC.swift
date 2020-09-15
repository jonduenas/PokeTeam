//
//  CustomNavVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/12/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class CustomNavVC: UINavigationController {

    var colorBlockView: ColorBlockView?
    var gradientView: GradientView!
    
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private var edgeSwipeGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe))
        edgeSwipeGestureRecognizer!.edges = .left
        view.addGestureRecognizer(edgeSwipeGestureRecognizer!)
        
        setupGradientView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if colorBlockView != nil {
            colorBlockView?.animateOnShow(completion: {
                // Set navigation bar color so scrolling doesn't overlap
                self.navigationBar.setNavigationBarColor(to: #colorLiteral(red: 0.8509803922, green: 0.2196078431, blue: 0.2666666667, alpha: 1), backgroundEffect: nil)
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if colorBlockView != nil {
            // Set navigation bar back to clear so it doesn't cover animation of color block
            self.navigationBar.setNavigationBarColor(to: .clear, backgroundEffect: nil)
        }
    }
    
    @objc func handleSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let percent = gestureRecognizer.translation(in: gestureRecognizer.view!).x / gestureRecognizer.view!.bounds.size.width
        
        if gestureRecognizer.state == .began {
            interactionController = UIPercentDrivenInteractiveTransition()
            popViewController(animated: true)
        } else if gestureRecognizer.state == .changed {
            interactionController?.update(percent)
        } else if gestureRecognizer.state == .ended {
            if percent > 0.5 && gestureRecognizer.state != .cancelled {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            
            interactionController = nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func setupGradientView() {
        let gradientView = GradientView()
        gradientView.gradientLayer.type = .axial
        gradientView.gradientLayer.colors = [UIColor(red: 220 / 255, green: 234 / 255, blue: 236 / 255, alpha: 1).cgColor, UIColor.white.cgColor, UIColor(red: 255 / 255, green: 244 / 255, blue: 253 / 255, alpha: 1).cgColor]
        gradientView.frame = view.bounds
        view.insertSubview(gradientView, at: 0)
    }
    
    func setupColorBlock(bottomColor: UIColor, topColor: UIColor, fillScreen: Bool) {
        colorBlockView = ColorBlockView()
        colorBlockView?.bottomColor = bottomColor
        colorBlockView?.topColor = topColor
        colorBlockView?.fillScreen = fillScreen
        
        view.insertSubview(colorBlockView!, at: 1)
    }
}
