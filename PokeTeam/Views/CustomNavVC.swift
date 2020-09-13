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

        let radialGradientView = RadialGradient()
        radialGradientView.frame = view.bounds
        view.insertSubview(radialGradientView, at: 0)
        // Do any additional setup after loading the view.
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
