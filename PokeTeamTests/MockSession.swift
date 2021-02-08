//
//  MockSession.swift
//  PokeTeamTests
//
//  Created by Jon Duenas on 1/26/21.
//  Copyright © 2021 Jon Duenas. All rights reserved.
//

import Foundation
import Combine
@testable import PokeTeam

final class MockSession: NetworkSession {
    var data: Data = .init()
    var response = HTTPURLResponse()
    
    func dataPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        Just((data: data, response: response))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
}
