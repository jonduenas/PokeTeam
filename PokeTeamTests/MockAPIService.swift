//
//  MockAPIService.swift
//  PokeTeamTests
//
//  Created by Jon Duenas on 1/23/21.
//  Copyright © 2021 Jon Duenas. All rights reserved.
//

import Foundation
import Combine
@testable import PokeTeam

class MockAPIService: APIService_Protocol {
    let urlSession: NetworkSession
    
    required init(networkSession: NetworkSession = MockSession()) {
        self.urlSession = networkSession
    }

    var fetchWasCalled: Bool = false
    var fetchAllWasCalled: Bool = false
    var currentValueSubject: CurrentValueSubject<Any, Error>!
    var currentValueSubjectArray: CurrentValueSubject<Any, Error>!
    
    func fetch<T>(type: T.Type, from url: URL) -> AnyPublisher<T, Error> where T : Decodable {
        fetchWasCalled = true
        
        return currentValueSubject
            .map({ $0 as! T })
            .eraseToAnyPublisher()
    }
    
    func fetchAll<T>(type: T.Type, from url: URL) -> AnyPublisher<[T], Error> where T : Decodable {
        fetchAllWasCalled = true
        
        return currentValueSubjectArray
            .map({ $0 as! [T] })
            .eraseToAnyPublisher()
    }
    
    func mockSessionTester(data: Data) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        let session = urlSession as! MockSession
        session.data = data
        
        let url = URL("http://testurl.com")
        
        return session.dataPublisher(for: URLRequest(url: url))
            
    }
    
    func createURL(for dataType: PokemonDataType, fromIndex index: Int?) -> URL? {
        let baseURL = URL("https://pokeapi.co/api/v2/")
        
        var returnURL = URL(string: dataType.rawValue, relativeTo: baseURL)
        
        if let indexNumber = index {
            // If index is set and not nil, add index to end of URL
            returnURL?.appendPathComponent(String(indexNumber))
        }
        
        return returnURL
    }
}
