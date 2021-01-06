//
//  APIServiceTests.swift
//  PokeTeamTests
//
//  Created by Jon Duenas on 1/6/21.
//  Copyright © 2021 Jon Duenas. All rights reserved.
//

import XCTest
@testable import PokeTeam

class APIServiceTests: XCTestCase {

    var sut: APIService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = APIService()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testCreateURL() {
        let dataType: PokemonDataType = .species
        let index = 25
        
        let testURL = sut.createURL(for: dataType, fromIndex: index)
        let testURL2 = sut.createURL(for: .allPokemon)
        
        XCTAssertNotNil(testURL)
        XCTAssertEqual(testURL?.absoluteString, "https://pokeapi.co/api/v2/pokemon-species/25")
        XCTAssertEqual(testURL2?.absoluteString, "https://pokeapi.co/api/v2/pokemon-species?limit=5000")
    }

}
