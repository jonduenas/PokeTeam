//
//  TypeCalculatorTests.swift
//  PokeTeamTests
//
//  Created by Jon Duenas on 11/25/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import XCTest
@testable import PokeTeam
import CoreData

class TypeCalculatorTests: XCTestCase {

    var sut: TypeCalculator!
    
    override func setUp() {
        super.setUp()
        
        sut = TypeCalculator()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func testSingleType() {
        
    }
}
