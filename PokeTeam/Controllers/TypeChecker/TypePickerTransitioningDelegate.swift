//
//  TypePickerTransitioningDelegate.swift
//  PokeTeam
//
//  Created by Jon Duenas on 12/3/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class TypePickerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    let height: CGFloat = 670
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentation = SlideOverPresentation(presentedViewController: presented, presenting: presenting)
        presentation.height = height
        return presentation
    }
}
