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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            self.navigationBar.setNavigationBarColor(to: .clear, backgroundEffect: nil)
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
