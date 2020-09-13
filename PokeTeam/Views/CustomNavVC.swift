//
//  CustomNavVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/12/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class CustomNavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let gradientView = GradientView()
        gradientView.gradientLayer.type = .axial
        gradientView.gradientLayer.colors = [UIColor(red: 243 / 255, green: 254 / 255, blue: 255 / 255, alpha: 1).cgColor, UIColor.white.cgColor, UIColor(red: 255 / 255, green: 244 / 255, blue: 253 / 255, alpha: 1).cgColor]
        gradientView.frame = view.bounds
        view.insertSubview(gradientView, at: 0)
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
