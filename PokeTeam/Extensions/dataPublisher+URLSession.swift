//
//  dataPublisher+URLSession.swift
//  PokeTeam
//
//  Created by Jon Duenas on 1/26/21.
//  Copyright © 2021 Jon Duenas. All rights reserved.
//

import Foundation
import Combine

protocol NetworkSession {
    func dataPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: NetworkSession {
    func dataPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}
