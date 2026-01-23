//
//  AuthAPI.swift
//  RaveView
//
//  Created by Aniol Vergés Herrera on 23/1/26.
//

import Supabase

struct AuthAPI {
    let client: SupabaseClient

    func login(email: String, password: String) async throws {
        try await client.auth.signIn(
            email: email,
            password: password
        )
    }

    func logout() async throws {
        try await client.auth.signOut()
    }

    func currentSession() async -> Session? {
        return try? await client.auth.session
    }
}
