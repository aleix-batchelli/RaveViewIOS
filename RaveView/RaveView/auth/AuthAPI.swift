//
//  AuthAPI.swift
//  RaveView
//
//  Created by Aniol Vergés Herrera on 23/1/26.
//

import Foundation
import Supabase

struct AuthAPI {
    let client: SupabaseClient

    func login(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func logout() async throws {
        try await client.auth.signOut()
    }

    func currentSession() async -> Session? {
        return try? await client.auth.session
    }

    func register(email: String, password: String, username: String, displayName: String?) async throws {
        let response = try await client.auth.signUp(email: email, password: password)

        let userId = response.user.id

        struct ProfileInsert: Encodable {
            let id: String
            let username: String
            let display_name: String?
            let avatar_url: String?
            let is_admin: Bool
            let followers_count: Int
            let following_count: Int
        }

        let payload = ProfileInsert(
            id: userId.uuidString.lowercased(),
            username: username,
            display_name: username,
            avatar_url: nil,
            is_admin: false,
            followers_count: 0,
            following_count: 0
        )

        try await client
            .from("profiles")
            .insert(payload)
            .execute()
    }
}

