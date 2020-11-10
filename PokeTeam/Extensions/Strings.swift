//
//  Strings.swift
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
        default:
            return self.capitalized
        }
    }
    
    func isSpecialVariety() -> (Bool, String?) {
        switch self {
        case "minior-red-meteor":
            return (true, "minior-meteor")
        case "minior-red":
            return (true, "minior-core")
        case self where self.hasPrefix("minior"):
            return (true, nil)
        case self where self.hasSuffix("totem"):
            return (true, nil)
        case self where self.hasSuffix("totem-alola"):
            return (true, nil)
        case "zygarde-50":
            return (true, nil)
        case "greninja-battle-bond":
            return (true, nil)
        default:
            return (false, self)
        }
    }
    
    func replaceSpecialNames() -> String {
        switch self {
        case "zygarde":
            return "zygarde-50"
        case "mimikyu-disguised":
            return "mimikyu"
        case "minior-red-meteor":
            return "minior-meteor"
        case "minior-red":
            return "minior-core"
        default:
            return self
        }
    }
}
