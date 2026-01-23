//
//  SupaBaseApi.swift
//  RaveView
//
//  Created by Aniol Vergés Herrera on 23/1/26.
//

import Supabase
import Foundation

// MARK: - API
struct DJSetsAPI {
    let client: SupabaseClient

    func fetchTopByReviews(limit: Int = 10) async throws -> [DJSet] {
        try await client
            .from("dj_sets")
            .select()
            .order("ratings_count", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func searchSets(query: String, limit: Int = 30) async throws -> [DJSet] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }

        let pattern = "*\(q)*"

        return try await client
            .from("dj_sets")
            .select()
            .or("title.ilike.\(pattern),artist_name.ilike.\(pattern)")
            .limit(limit)
            .execute()
            .value
    }
    
    func fetchReviews(query: UUID, limit: Int = 30) async throws -> [Review] {
        return try await client
            .from("reviews")
            .select()
            .eq("set_id", value: query.uuidString.lowercased())
            .execute()
            .value
    }
    
    func fetchReviewsWithProfiles(forSetId setId: UUID, limit: Int = 30) async throws -> [ReviewWithProfile] {
        try await client
            .from("reviews")
            .select("""
                id,
                set_id,
                user_id,
                rating,
                comment,
                was_present,
                created_at,
                updated_at,
                profiles(
                    id,
                    username,
                    display_name,
                    avatar_url,
                    is_admin,
                    followers_count,
                    following_count,
                    created_at
                )
            """)
            .eq("set_id", value: setId.uuidString)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }
    
    func fetchMyProfile() async throws -> Profile {
        let session = try await client.auth.session
        let userId = session.user.id

        return try await client
            .from("profiles")
            .select("""
                id,
                username,
                display_name,
                avatar_url,
                is_admin,
                followers_count,
                following_count,
                created_at
            """)
            .eq("id", value: userId.uuidString.lowercased())
            .single()
            .execute()
            .value
    }

    func fetchProfile(id: UUID) async throws -> Profile {
        try await client
            .from("profiles")
            .select("""
                id,
                username,
                display_name,
                avatar_url,
                is_admin,
                followers_count,
                following_count,
                created_at
            """)
            .eq("id", value: id.uuidString.lowercased())
            .single()
            .execute()
            .value
    }
    
    func fetchMyReviews(limit: Int = 30) async throws -> [Review] {
        let session = try await client.auth.session
        let userId = session.user.id

        return try await client
            .from("reviews")
            .select()
            .eq("user_id", value: userId.uuidString.lowercased())
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

}
