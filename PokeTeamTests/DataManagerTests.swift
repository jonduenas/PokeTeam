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
    
    func testCoreDataSave() {
        expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataStack.mainContext) { _ in
            return true
        }
        
        sut.managedObjectContext.perform {
            let pokemon = self.sut.addPokemon(name: "bulbasaur", speciesURL: "testurl", id: 1)
            
            XCTAssertNotNil(pokemon)
            
            self.coreDataStack.saveContext(self.sut.managedObjectContext)
        }
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    func testRootContextIsSaved() {
        let derivedContext = coreDataStack.newDerivedContext()
        let derivedSut = DataManager(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataStack.mainContext) { _ in
            return true
        }
        
        derivedSut.managedObjectContext.perform {
            let pokemon = derivedSut.addPokemon(name: "squirtle", speciesURL: "http://testurl.com", id: 7)
            
            XCTAssertNotNil(pokemon)
            
            self.coreDataStack.saveContext(derivedContext)
        }
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    func testAddAbility_AddAbilityDetails() {
        let abilityDetails = sut.addAbilityDetails(abilityName: "imposter", url: "http://testurl.com")
        
        let ability = sut.addAbility(abilityName: "imposter", pokemonName: "ditto", isHidden: false, slot: 0, abilityDetails: abilityDetails)
        
        XCTAssertNotNil(ability)
        XCTAssertNotNil(abilityDetails)
        XCTAssertEqual(abilityDetails.name, "imposter")
        XCTAssertEqual(abilityDetails.urlString, "http://testurl.com")
        XCTAssertEqual(ability.name, "ditto-imposter")
        XCTAssertEqual(ability.isHidden, false)
        XCTAssertEqual(ability.slot, 0)
        XCTAssertEqual(ability.abilityDetails, abilityDetails)
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
    
    func testGetFromCoreData() {
        sut.addPokemon(name: "pikachu", speciesURL: "testurl", id: 10)
        sut.addPokemon(name: "bulbasaur", speciesURL: "testurl", id: 20)
        sut.addPokemon(name: "squirtle", speciesURL: "testurl", id: 30)
        sut.addPokemon(name: "charmander", speciesURL: "testurl", id: 40)
        
        let allPokemon = sut.getFromCoreData(entity: PokemonMO.self, sortBy: "id", isAscending: true) as? [PokemonMO]
        
        XCTAssertNotNil(allPokemon)
        XCTAssertEqual(allPokemon?.count, 4)
        XCTAssertEqual(allPokemon?[1].name, "bulbasaur")
    }
    
    func testUpdateDetails_SpeciesData() {
        // Create test Pokemon MO
        let pokemon = sut.addPokemon(name: "mewtwo", varietyName: "mewtwo", speciesURL: "https://pokeapi.co/api/v2/pokemon-species/150/", pokemonURL: "https://pokeapi.co/api/v2/pokemon/150/", id: 150)
        
        sut.coreDataStack.saveContext(sut.managedObjectContext)
        
        let managedObjectID = pokemon.objectID
        
        // Inject test JSON file and decode to SpeciesData
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "mewtwo", withExtension: "json") else {
            XCTFail("Missing mewtwo.json file")
            return
        }
        
        let testJSON = try? Data(contentsOf: url)
        
        let speciesData = try? jsonDecoder.decode(SpeciesData.self, from: testJSON!)
        
        // Test updateDetails(for:with:)
        let updatedPokemon = sut.updateDetails(for: managedObjectID, with: speciesData!)
        
        XCTAssertNotNil(updatedPokemon)
        XCTAssertNotEqual(updatedPokemon.genus, "")
        XCTAssertNotEqual(updatedPokemon.generation, "")
        XCTAssertNotNil(updatedPokemon.flavorText)
        XCTAssertEqual(updatedPokemon.isBaby, false)
        XCTAssertEqual(updatedPokemon.isLegendary, true)
        XCTAssertEqual(updatedPokemon.isMythical, false)
        XCTAssertNotEqual(updatedPokemon.nationalPokedexNumber, 0)
        XCTAssertNotEqual(updatedPokemon.order, 0)
        XCTAssertNotEqual(updatedPokemon.pokemonURL, "")
        XCTAssertEqual(updatedPokemon.varieties?.count, 2)
    }
    
    func testUpdateDetails_PokemonData() {
        // Create test Pokemon MO
        let pokemon = sut.addPokemon(name: "unown", speciesURL: "http://testurl.com", id: 201)
        let managedObjectID = pokemon.objectID
        
        // Inject test JSON file and decode to SpeciesData
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "unown", withExtension: "json") else {
            XCTFail("Missing unown.json file")
            return
        }
        
        let testJSON = try? Data(contentsOf: url)
        
        let pokemonData = try? jsonDecoder.decode(PokemonData.self, from: testJSON!)
        
        // Test updateDetails(for:with:)
        let updatedPokemon = sut.updateDetails(for: managedObjectID, with: pokemonData!)
        
        XCTAssertNotEqual(updatedPokemon.imageID, "")
        XCTAssertNotEqual(updatedPokemon.height, 0)
        XCTAssertNotEqual(updatedPokemon.weight, 0)
        XCTAssertNotNil(updatedPokemon.type)
        XCTAssertNotNil(updatedPokemon.stats)
        XCTAssertNotEqual(updatedPokemon.abilities?.count, 0)
        XCTAssertNotEqual(updatedPokemon.moves?.count, 0)
        XCTAssertEqual(updatedPokemon.hasAltForm, true)
        XCTAssertNotEqual(updatedPokemon.altForm?.count, 0)
    }
    
    func testUpdateDetails_FormData() {
        let altForm = AltFormMO(context: sut.managedObjectContext)
        altForm.name = "unown-a"
        altForm.urlString = "http://testurl.com"
        
        let managedObjectID = altForm.objectID
        
        let formA = FormData(id: 201, name: "unown-a", order: 283, formOrder: 1, isDefault: true, isMega: false, formName: "a", pokemon: NameAndURL(name: "unown", url: "http://testurl.com"))
        
        let updatedAltForm = sut.updateDetails(for: managedObjectID, with: formA)
        
        XCTAssertEqual(updatedAltForm.name, "unown-a")
        XCTAssertEqual(updatedAltForm.formName, "a")
        XCTAssertEqual(updatedAltForm.order, 283)
        XCTAssertEqual(updatedAltForm.formOrder, 1)
        XCTAssertEqual(updatedAltForm.id, 201)
    }
    
    func testAddAbilityDescription() {
        let ability = AbilityMO(context: sut.managedObjectContext)
        ability.name = "pokemon-battle-armor"
        ability.isHidden = false
        ability.slot = 1
        
        let abilityDetails = AbilityDetails(context: sut.managedObjectContext)
        abilityDetails.name = "battle-armor"
        abilityDetails.urlString = "http://testurl.com"
        
        ability.abilityDetails = abilityDetails

        let managedObjectID = abilityDetails.objectID
        
        // Inject test JSON file and decode to SpeciesData
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "battle-armor", withExtension: "json") else {
            XCTFail("Missing battle-armor.json file")
            return
        }
        
        let testJSON = try? Data(contentsOf: url)
        
        let abilityData = try? jsonDecoder.decode(AbilityData.self, from: testJSON!)
        
        let updatedAbility = sut.addAbilityDescription(to: managedObjectID, with: abilityData!)
        
        XCTAssertNotEqual(updatedAbility.abilityDescription, "")
        XCTAssertNotEqual(updatedAbility.id, 0)
    }
    
    func testAddPokemonVariety() {
        
    }
}
