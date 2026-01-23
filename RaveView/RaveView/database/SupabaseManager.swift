//
//  SupabaseManager.swift.swift
//  RaveView
//
//  Created by Aniol Vergés Herrera on 22/1/26.
//

import Supabase
import Foundation

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        let supabaseURL = URL(string: "https://hkmmnpjzlafjpyrsmcka.supabase.co")!
        let supabaseAnonKey = "sb_publishable_XVWBRvCPqxw5yEmGqDHUdw_E0LLzY66"

        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnonKey
        )
    }
}
