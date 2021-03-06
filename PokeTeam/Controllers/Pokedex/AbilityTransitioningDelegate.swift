//
//  AbilityTransitioningDelegate.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/13/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class AbilityTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentation = SlideOverPresentation(presentedViewController: presented, presenting: presenting)
        presentation.height = 300
        return presentation
    }
}
