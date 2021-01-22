//
//  PokedexVCTests.swift
//  PokeTeamTests
//
//  Created by Jon Duenas on 1/20/21.
//  Copyright © 2021 Jon Duenas. All rights reserved.
//

import XCTest
@testable import PokeTeam

class PokedexVCTests: XCTestCase {

    var sut: PokedexVC!
    
    override func setUp() {
        super.setUp()
        
        let testCoreDataStack = TestCoreDataStack()
        
        let storyboard = UIStoryboard(name: "Pokedex", bundle: nil)
        sut = storyboard.instantiateInitialViewController() as? PokedexVC
        sut.coreDataStack = testCoreDataStack
        sut.backgroundDataManager = DataManager(managedObjectContext: testCoreDataStack.mainContext, coreDataStack: testCoreDataStack)
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }

    
}
