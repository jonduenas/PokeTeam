//
//  ActivityIndicator.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/13/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

extension UIView {
    func activityIndicator(style: UIActivityIndicatorView.Style = .medium, frame: CGRect? = nil, center: CGPoint? = nil) -> UIActivityIndicatorView {
        let activityViewIndicator = UIActivityIndicatorView(style: style)
        
        if let frame = frame {
            activityViewIndicator.frame = frame
        }
        
        if let center = center {
            activityViewIndicator.center = center
        }
        
        return activityViewIndicator
    }
}
