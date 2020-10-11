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

    var sut: DataManager!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        coreDataStack = TestCoreDataStack()
        sut = DataManager(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }

    override func tearDown() {
        coreDataStack = nil
        sut = nil
        super.tearDown()
    }
    
    func testAddPokemon() {
        let pokemon = sut.addPokemon(name: "pikachu", speciesURL: "http://testurl.com", id: 4)
        
        XCTAssertNotNil(pokemon, "Pokemon should not be nil")
        XCTAssertTrue(pokemon.name == "pikachu")
        XCTAssertTrue(pokemon.speciesURL == "http://testurl.com")
        XCTAssertTrue(pokemon.id == 4)
    }
    
    func testAddTeam() {
        let newTeam = sut.addTeam()
        
        XCTAssertNotNil(newTeam)
    }

    func testUpdatePokedex() {
        // given
        let pokemon1 = NameAndURL(name: "Pikachu", url: "https://pokeapi.co/api/v2/pokemon-species/1/")
        let pokemon2 = NameAndURL(name: "Bulbasaur", url: "https://pokeapi.co/api/v2/pokemon-species/2/")
        let pokemon3 = NameAndURL(name: "Squirtle", url: "https://pokeapi.co/api/v2/pokemon-species/3/")
        let pokemon4 = NameAndURL(name: "Charmander", url: "https://pokeapi.co/api/v2/pokemon-species/4/")
        
        let testPokedex = NationalPokedex(count: 4, results: [pokemon1, pokemon2, pokemon3, pokemon4])
        
        // when
        let testPokemonArray = sut.updatePokedex(pokedex: testPokedex)
        
        // then
        XCTAssertEqual(testPokemonArray.count, 4, "testPokemonArray count should be 4")
        XCTAssertEqual(testPokemonArray[1].id, 2, "ID should be 2")
    }
    
    func testUpdateDetails() {
        // Create test Pokemon MO
        let pokemon = sut.addPokemon(name: "pikachu", speciesURL: "http://testurl.com", id: 25)
        let managedObjectID = pokemon.objectID
        
        // Inject test JSON file and decode to SpeciesData
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "pikachu", withExtension: "json") else {
            XCTFail("Missing pikachu.json file")
            return
        }
        
        let testJSON = try? Data(contentsOf: url)
        
        let speciesData = try? jsonDecoder.decode(SpeciesData.self, from: testJSON!)
        
        // Test updateDetails(for:with:)
        let updatedPokemon = sut.updateDetails(for: managedObjectID, with: speciesData!)
        
        XCTAssertNotNil(updatedPokemon)
        XCTAssertNotNil(updatedPokemon.genus)
        XCTAssertNotNil(updatedPokemon.generation)
        XCTAssertNotNil(updatedPokemon.flavorText)
        XCTAssertNotNil(updatedPokemon.isBaby)
        XCTAssertNotNil(updatedPokemon.isLegendary)
        XCTAssertNotNil(updatedPokemon.isMythical)
        XCTAssertNotNil(updatedPokemon.nationalPokedexNumber)
        XCTAssertNotNil(updatedPokemon.order)
        XCTAssertNotNil(updatedPokemon.pokemonURL)
    }
}
