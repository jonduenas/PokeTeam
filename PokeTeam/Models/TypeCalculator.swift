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
    
    var type1: TypeMO? {
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
    
    init(type1: TypeMO?, type2: TypeMO?, allTypes: [TypeMO]) {
        self.type1 = type1
        self.type2 = type2
        self.allTypes = allTypes
    }
    
    func parseDamageRelations() {
        resetAllTypeDamageRelations()
        
        if (type1 == nil && type2 != nil) || (type2 == nil && type1 != nil) {
            if let type1_ = type1 {
                parseOneType(type: type1_)
            } else {
                parseOneType(type: type2!)
            }
        } else if type1 != nil && type2 != nil {
            parseTwoTypes(type1!, type2!)
        } else {
            print("Error parsing types. Both are set to nil.")
        }
    }
    
    private func parseOneType(type: TypeMO) {
        weakTo = type.doubleDamageFrom as? Set<TypeMO> ?? []
        resistantTo = type.halfDamageFrom as? Set<TypeMO> ?? []
        immuneTo = type.noDamageFrom as? Set<TypeMO> ?? []
        
        addUnusedTypesToNormalDamage()
    }
    
    private func parseTwoTypes(_ type1: TypeMO, _ type2: TypeMO) {
        let type1DoubleDamage = type1.doubleDamageFrom as? Set<TypeMO> ?? []
        let type1HalfDamage = type1.halfDamageFrom as? Set<TypeMO> ?? []
        let type1NoDamage = type1.noDamageFrom as? Set<TypeMO> ?? []
        
        let type2DoubleDamage = type2.doubleDamageFrom as? Set<TypeMO> ?? []
        let type2HalfDamage = type2.halfDamageFrom as? Set<TypeMO> ?? []
        let type2NoDamage = type2.noDamageFrom as? Set<TypeMO> ?? []
        
        var doubleDamageCount = calculateTwoDamageRelations(type1DamageRelation: type1DoubleDamage, type2DamageRelation: type2DoubleDamage)
        var halfDamageCount = calculateTwoDamageRelations(type1DamageRelation: type1HalfDamage, type2DamageRelation: type2HalfDamage)
        immuneTo = type1NoDamage.union(type2NoDamage)
        
        for key in doubleDamageCount.keys {
            if halfDamageCount.keys.contains(key) {
                // If a Pokemon has 2 types and one type is weak to something while the other type resists, it makes damage normal.
                // Remove type from both doubleDamageCount and halfDamageCount so it will fall into normal damage
                doubleDamageCount.removeValue(forKey: key)
                halfDamageCount.removeValue(forKey: key)
            }
        }
        
        for double in doubleDamageCount {
            if immuneTo.contains(double.key) {
                continue
            }
            
            if double.value > 1 {
                superWeakTo.insert(double.key)
            } else {
                weakTo.insert(double.key)
            }
        }
        
        for half in halfDamageCount {
            if immuneTo.contains(half.key) {
                continue
            }
            
            if half.value > 1 {
                superResistantTo.insert(half.key)
            } else {
                resistantTo.insert(half.key)
            }
        }
        
        addUnusedTypesToNormalDamage()
    }
    
    private func calculateTwoDamageRelations(type1DamageRelation: Set<TypeMO>, type2DamageRelation: Set<TypeMO>) -> [TypeMO: Int] {
        var damageRelationCount = [TypeMO: Int]()
        
        for type in type1DamageRelation {
            damageRelationCount[type, default: 0] += 1
        }
        
        for type in type2DamageRelation {
            damageRelationCount[type, default: 0] += 1
        }
        
        return damageRelationCount
    }
    
    private func addUnusedTypesToNormalDamage() {
        let usedTypes = weakTo.union(resistantTo).union(immuneTo).union(superResistantTo).union(superWeakTo)
        
        normalDamage = Set(allTypes.filter { !usedTypes.contains($0) })
    }
    
    private func resetAllTypeDamageRelations() {
        superWeakTo.removeAll()
        weakTo.removeAll()
        normalDamage.removeAll()
        resistantTo.removeAll()
        superResistantTo.removeAll()
        normalDamage.removeAll()
        immuneTo.removeAll()
    }
}
