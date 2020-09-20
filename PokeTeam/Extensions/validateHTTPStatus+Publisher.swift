//
//  validateHTTPStatus+Publisher.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/22/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation
import Combine

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
  func validateHTTPStatus(_ expectedStatus: Int) -> Publishers.TryMap<Self, Data> {
    tryMap { output in
      if let response = output.response as? HTTPURLResponse, response.statusCode == expectedStatus {
        return output.data
      } else {
        throw SomeError.unexpectedResponse(output.response)
      }
    }
  }
}

enum SomeError: Error {
    case unexpectedResponse(_: URLResponse)
}
