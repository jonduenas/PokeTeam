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
    
    func replacingFirstOccurrence(of target: String, with replacement: String) -> String {
        guard let range = self.range(of: target) else { return self }
        return self.replacingCharacters(in: range, with: replacement)
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
        case "sirfetchd":
            return "Sirfetch'd"
        case "mr-mime":
            return "Mr. Mime"
        case "mr-rime":
            return "Mr. Rime"
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
        case "ho-oh":
            return "Ho-Oh"
        default:
            return self.capitalized
        }
    }
    
    func formatVarietyName(speciesName: String) -> String {
        let megaString = "mega"
        let primalString = "primal"
        let basculinString = "striped"
        let zygardeString = "zygarde"
        let miniorString = "minior"
        let necrozmaString = "necrozma"
        let urshifuString = "urshifu"
        let calyrexString = "calyrex"
        
        if self.contains(megaString) {
            let name = megaString + " " + self.replacingOccurrences(of: megaString, with: "").replacingOccurrences(of: "--", with: " ").replacingOccurrences(of: "-", with: "")
            
            return name.capitalized
        } else if self.contains("primal") {
            let name = primalString + " " + self.replacingOccurrences(of: primalString, with: "").replacingOccurrences(of: "-", with: "")
            
            return name.capitalized
        } else if self.contains(basculinString) {
            let name = self.replacingOccurrences(of: speciesName, with: "").replacingFirstOccurrence(of: "-", with: "")
            return name.capitalized
        } else if self.contains(urshifuString) || self.contains(calyrexString) {
            let name = self.replacingOccurrences(of: speciesName, with: "").replacingOccurrences(of: "-", with: " ")
            return name.capitalized
        } else {
            var name = self.replacingOccurrences(of: speciesName, with: "").replacingOccurrences(of: "--", with: " ").replacingOccurrences(of: "-", with: "")
            if speciesName == zygardeString && (name == "10" || name == "50") {
                name += "%"
            } else if speciesName == miniorString {
                name = (name == "red" ? "core" : "meteor")
            } else if speciesName == necrozmaString {
                if name == "dusk" {
                    name += " mane"
                } else if name == "dawn" {
                    name += " wings"
                } else if name == "ultra" {
                    name = name + " " + speciesName
                }
            }
            return name.capitalized
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
