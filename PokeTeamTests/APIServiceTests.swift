//
//  APIServiceTests.swift
//  PokeTeamTests
//
//  Created by Jon Duenas on 1/6/21.
//  Copyright © 2021 Jon Duenas. All rights reserved.
//

import XCTest
import Combine
@testable import PokeTeam

class APIServiceTests: XCTestCase {

    var sut: APIService!
    var mockNetworkSession: MockSession!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockNetworkSession = MockSession()
        sut = APIService(networkSession: mockNetworkSession)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func loadJSON(named filename: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            XCTFail("Missing \(filename).json file")
            return nil
        }
        
        return try? Data(contentsOf: url)
    }
   
    func testFetch_withFail_unexpectedResponse() {
        var subscriptions: Set<AnyCancellable> = []
        
        let url =  URL("https://pokeapi.co/api/v2/pokemon/ditto")
        let mockResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!
        mockNetworkSession.response = mockResponse
        
        sut.fetch(type: SpeciesData.self, from: url)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    XCTAssertEqual(error as? HTTPError, HTTPError.unexpectedResponse(mockResponse))
                default:
                    XCTFail()
                }
            } receiveValue: { _ in
                XCTFail()
            }
            .store(in: &subscriptions)
    }
    
    func testFetch_withFail_badJSON() {
        var subscriptions: Set<AnyCancellable> = []
        
        // Loads Ability Data JSON but expects Species Data
        guard let abilityJSON = loadJSON(named: "battle-armor") else {
            XCTFail("Error loading JSON file")
            return
        }
        
        mockNetworkSession.data = abilityJSON
        let url = URL("https://pokeapi.co/api/v2/pokemon/ditto")
        let mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockNetworkSession.response = mockResponse
        
        sut.fetch(type: SpeciesData.self, from: url)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    XCTAssertNotNil(error)
                default:
                    XCTFail()
                }
            } receiveValue: { _ in
                XCTFail()
            }
            .store(in: &subscriptions)
    }
    
    func testFetch() {
        var subscriptions: Set<AnyCancellable> = []
        
        guard let speciesJSON = loadJSON(named: "mewtwo") else {
            XCTFail("Error loading JSON file")
            return
        }
        
        mockNetworkSession.data = speciesJSON
        let url = URL("https://pokeapi.co/api/v2/pokemon-species/mewtwo")
        mockNetworkSession.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        sut.fetch(type: SpeciesData.self, from: url)
            .sink { completion in
                switch completion {
                case .failure(_):
                    XCTFail()
                default:
                    break
                }
            } receiveValue: { data in
                XCTAssertNotNil(data)
                XCTAssertEqual(data.name, "mewtwo")
            }
            .store(in: &subscriptions)
    }
    
    func testCreateURL() {
        let dataType: PokemonDataType = .species
        let index = 25

        let testURL = sut.createURL(for: dataType, fromIndex: index)
        let testURL2 = sut.createURL(for: .allPokemon)

        XCTAssertNotNil(testURL)
        XCTAssertEqual(testURL?.absoluteString, "https://pokeapi.co/api/v2/pokemon-species/25")
        XCTAssertNotNil(testURL2)
        XCTAssertEqual(testURL2?.absoluteString, "https://pokeapi.co/api/v2/pokemon-species?limit=5000")
    }

}
