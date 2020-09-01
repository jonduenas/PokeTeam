//
//  StringFormatting.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

extension String {
    init(withInt int: Int, leadingZeros: Int = 1) {
        self.init(format: "%0\(leadingZeros)d", int)
    }

    func leadingZeros(_ zeros: Int) -> String {
        if let int = Int(self) {
            return String(withInt: int, leadingZeros: zeros)
        }
        print("Warning: \(self) is not an Int")
        return ""
    }
    
    func formatAbilityName() -> String {
        if self == "soul-heart" {
            return self.capitalized
        } else {
            return self.capitalized.replacingOccurrences(of: "-", with: " ")
        }
    }
    
    func formatPokemonName() -> String {
        switch self {
        case "nidoran-m":
            return "Nidoran ♂"
        case "nidoran-f":
            return "Nidoran ♀"
        case "farfetchd":
            return "Farfetch'd"
        case "mr-mime":
            return "Mr. Mime"
        case "mime-jr":
            return "Mime Jr."
        case "type-null":
            return "Type: Null"
        case "tapu-koko":
            return "Tapu Koko"
        case "tapu-lele":
            return "Tapu Lele"
        case "tapu-bulu":
            return "Tapu Bulu"
        case "tapu-fini":
            return "Tapu Fini"
//        case "ho-oh":
//            return "Ho-Oh"
//        case "porygon-z":
//            return "Porygon-Z"
//        case "jangmo-o":
//            return "Jangmo-O"
//        case "hakamo-o":
//            return "Hakamo-O"
//        case "kommo-o":
//            return "Kommo-O"
        default:
//            if let index = self.range(of: "-")?.lowerBound {
//                // Returns capitalized string and removes the default form name
//                return String(self.capitalized.prefix(upTo: index))
//            }
            return self.capitalized
        }
    }
}
