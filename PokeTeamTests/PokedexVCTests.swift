//
//  PokedexVCTests.swift
//  PokeTeamTests
//
//  Created by Jon Duenas on 1/20/21.
//  Copyright © 2021 Jon Duenas. All rights reserved.
//

import XCTest
import Combine
@testable import PokeTeam

class PokedexVCTests: XCTestCase {

    var sut: PokedexVC!
    var mockAPIService: MockAPIService!
    
    override func setUp() {
        super.setUp()
        
        mockAPIService = MockAPIService()
        mockAPIService.currentValueSubject = CurrentValueSubject(createValidTestObject())
        mockAPIService.currentValueSubjectArray = CurrentValueSubject(createValidTestObjectArray())
        
        let testCoreDataStack = TestCoreDataStack()
        let dataManager = DataManager(managedObjectContext: testCoreDataStack.mainContext, coreDataStack: testCoreDataStack)
        
        let storyboard = UIStoryboard(name: "Pokedex", bundle: .main)
        sut = storyboard.instantiateViewController(identifier: "PokedexVC") { coder in
            PokedexVC(coder: coder, coreDataStack: testCoreDataStack, dataManager: dataManager)
        }
        sut.apiService = mockAPIService
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func createValidTestObject() -> ResourceList {
        return ResourceList(count: 100, results: [])
    }
    
    func createValidTestObjectArray() -> [TypeData] {
        return [TypeData(name: "normal", id: 1, damageRelations: DamageRelation(doubleDamageFrom: [], doubleDamageTo: [], halfDamageFrom: [], halfDamageTo: [], noDamageFrom: [], noDamageTo: []))]
    }
    
    func testInitialLoadingState() {
        XCTAssertTrue(sut.indicatorView.isAnimating)
    }
}
