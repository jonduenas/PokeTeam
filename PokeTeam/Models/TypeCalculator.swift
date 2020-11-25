//
//  TypeCalculator.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/25/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation

public final class TypeCalculator {
    let allTypes: [TypeMO]
    
    var type1: TypeMO {
        didSet {
            parseDamageRelations()
        }
    }
    
    var type2: TypeMO? {
        didSet {
            parseDamageRelations()
        }
    }
    
    var superWeakTo = Set<TypeMO>()
    var weakTo = Set<TypeMO>()
    var normalDamage = Set<TypeMO>()
    var resistantTo = Set<TypeMO>()
    var superResistantTo = Set<TypeMO>()
    var immuneTo = Set<TypeMO>()
    
    init(type1: TypeMO, type2: TypeMO?, allTypes: [TypeMO]) {
        self.type1 = type1
        self.type2 = type2
        self.allTypes = allTypes
    }
    
    func calculateTwoDamageRelations(type1DamageRelation: Set<TypeMO>, type2DamageRelation: Set<TypeMO>) -> [TypeMO: Int] {
        var damageRelationCount = [TypeMO: Int]()
        
        let typeSequence = zip(type1DamageRelation, type2DamageRelation)
        
        for (typeA, typeB) in typeSequence {
            damageRelationCount[typeA, default: 0] += 1
            damageRelationCount[typeB, default: 0] += 1
        }
        
        return damageRelationCount
    }
    
    func parseDamageRelations() {
        if type2 == nil {
            weakTo = type1.doubleDamageFrom as? Set<TypeMO> ?? []
            resistantTo = type1.halfDamageFrom as? Set<TypeMO> ?? []
            immuneTo = type1.noDamageFrom as? Set<TypeMO> ?? []
            
            let usedTypes = weakTo.union(resistantTo).union(immuneTo)
            
            normalDamage = Set(allTypes.filter { !usedTypes.contains($0) })
        } else {
            let type1DoubleDamage = type1.doubleDamageFrom as? Set<TypeMO> ?? []
            let type1HalfDamage = type1.halfDamageFrom as? Set<TypeMO> ?? []
            let type1NoDamage = type1.noDamageFrom as? Set<TypeMO> ?? []
            
            let type2DoubleDamage = type2!.doubleDamageFrom as? Set<TypeMO> ?? []
            let type2HalfDamage = type2!.halfDamageFrom as? Set<TypeMO> ?? []
            let type2NoDamage = type2!.noDamageFrom as? Set<TypeMO> ?? []
            
            let doubleDamageCount = calculateTwoDamageRelations(type1DamageRelation: type1DoubleDamage, type2DamageRelation: type2DoubleDamage)
            let halfDamageCount = calculateTwoDamageRelations(type1DamageRelation: type1HalfDamage, type2DamageRelation: type2HalfDamage)
            let noDamage = type1NoDamage.union(type2NoDamage)
            
            let damageSequence = zip(doubleDamageCount, halfDamageCount)
            
            for (double, half) in damageSequence {
                if double.value > 1 {
                    // If the count exceeds 1, then it is super weak
                    superWeakTo.insert(double.key)
                } else if noDamage.contains(double.key) {
                    // If any type does no damage, regardless of it doing double to the other type, then it is immune
                    immuneTo.insert(double.key)
                } else {
                    weakTo.insert(double.key)
                }
                
                if half.value > 1 {
                    superResistantTo.insert(half.key)
                } else if noDamage.contains(half.key) {
                    immuneTo.insert(half.key)
                } else {
                    resistantTo.insert(half.key)
                }
            }
        }
    }
}
