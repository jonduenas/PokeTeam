//
//  URL.swift
//  PokeTeam
//
//  Created by Jon Duenas on 1/6/21.
//  Copyright © 2021 Jon Duenas. All rights reserved.
//

import Foundation

extension URL {
    // Auto unwraps URLs from strings
    init(_ string: StaticString) {
        self.init(string: "\(string)")!
    }
}
