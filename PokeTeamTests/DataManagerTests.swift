//
//  DataManagerTests.swift
//  PokeTeamTests
//
//  Created by Jon Duenas on 9/20/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import XCTest
@testable import PokeTeam
import CoreData

class DataManagerTests: XCTestCase {

    var dataManager: DataManager!
    var coreDataStack: CoreDataStack!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataStack = TestCoreDataStack()
        dataManager = DataManager(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }

    override func tearDownWithError() throws {
        coreDataStack = nil
        dataManager = nil
        try super.tearDownWithError()
    }
    
    func testAddPokemon() {
        let pokemon = dataManager.addPokemon(name: "pikachu", speciesURL: "http://testurl.com", id: 4)
        
        XCTAssertNotNil(pokemon, "Pokemon should not be nil")
        XCTAssertTrue(pokemon.name == "pikachu")
        XCTAssertTrue(pokemon.speciesURL == "http://testurl.com")
        XCTAssertTrue(pokemon.id == 4)
    }

    func testUpdatePokedex() {
        // given
        let pokemon1 = NameAndURL(name: "Pikachu", url: "https://pokeapi.co/api/v2/pokemon-species/1/")
        let pokemon2 = NameAndURL(name: "Bulbasaur", url: "https://pokeapi.co/api/v2/pokemon-species/2/")
        let pokemon3 = NameAndURL(name: "Squirtle", url: "https://pokeapi.co/api/v2/pokemon-species/3/")
        let pokemon4 = NameAndURL(name: "Charmander", url: "https://pokeapi.co/api/v2/pokemon-species/4/")
        
        let testPokedex = NationalPokedex(count: 4, results: [pokemon1, pokemon2, pokemon3, pokemon4])
        
        // when
        let testPokemonArray = dataManager.updatePokedex(pokedex: testPokedex)
        
        // then
        XCTAssertEqual(testPokemonArray.count, 4, "testPokemonArray count should be 4")
        XCTAssertEqual(testPokemonArray[1].id, 2, "ID should be 2")
    }
}
