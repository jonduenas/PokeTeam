//
//  TypeData.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/21/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

struct TypeData: Codable {
    let name: String
    let id: Int
    let damageRelations: DamageRelation
}

struct DamageRelation: Codable {
    let doubleDamageFrom: [NameAndURL]
    let doubleDamageTo: [NameAndURL]
    let halfDamageFrom: [NameAndURL]
    let halfDamageTo: [NameAndURL]
    let noDamageFrom: [NameAndURL]
    let noDamageTo: [NameAndURL]
}
