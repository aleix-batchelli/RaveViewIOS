//
//  dogAPI.swift
//  RaveView
//
//  Created by Aniol Vergés Herrera on 23/1/26.
//

import Foundation

struct DogAPI {
    struct Response: Decodable {
        let message: String  
        let status: String
    }

    static func fetchRandomImageURL() async throws -> String {
        let url = URL(string: "https://dog.ceo/api/breeds/image/random")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded.message
    }
}
