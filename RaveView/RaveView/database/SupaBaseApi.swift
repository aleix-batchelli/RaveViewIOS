//
//  SupaBaseApi.swift
//  RaveView
//
//  Created by Aniol Vergés Herrera on 23/1/26.
//

import Supabase
import Foundation
import UIKit

struct ReviewImageRow: Decodable {
    let review_id: Int
    let url: String
    let path: String?
    let created_at: String?
}


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
    
    func logout() {
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signOut()

                await MainActor.run {
                    // Volver al login
                    //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                }
            } catch {
                print("LOGOUT ERROR:", error)
            }
        }
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
    
    func fetchSetById(_ id: UUID) async throws -> DJSet {
            try await client
                .from("dj_sets")
                .select()
                .eq("id", value: id.uuidString.lowercased())
                .single()
                .execute()
                .value
    }
    
    func createReview(
        setId: UUID,
        rating: Int,
        comment: String?,
        wasPresent: Bool,
        image: UIImage?
    ) async throws {

        let user = try await client.auth.session.user
        let userId = user.id

        // 1) Insert review and get the created review id
        struct NewReviewRow: Encodable {
            let set_id: UUID
            let user_id: UUID
            let rating: Int
            let comment: String?
            let was_present: Bool
        }

        struct InsertedReview: Decodable {
            let id: Int
        }

        let payload = NewReviewRow(
            set_id: setId,
            user_id: userId,
            rating: rating,
            comment: comment,
            was_present: wasPresent
        )

        // IMPORTANT: we need the inserted row returned to get its id
        let inserted: InsertedReview = try await client
            .from("reviews")
            .insert(payload)
            .select("id")
            .single()
            .execute()
            .value

        // 2) If no image, we're done
        guard let image = image else { return }

        // 3) Upload image to Storage
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw NSError(domain: "ImageEncoding", code: 0)
        }

        let fileName = "\(UUID().uuidString.lowercased()).jpg"
        let path = "reviews/\(setId.uuidString.lowercased())/\(inserted.id)/\(fileName)"

        _ = try await client
            .storage
            .from("review-images")
            .upload(path, data: data)

        // If bucket is public: store public URL
        let publicURL = try client
            .storage
            .from("review-images")
            .getPublicURL(path: path)
            .absoluteString

        // 4) Insert into review_images
        struct NewReviewImageRow: Encodable {
            let review_id: Int
            let url: String
            let path: String
        }

        let imageRow = NewReviewImageRow(
            review_id: inserted.id,
            url: publicURL,
            path: path
        )


        _ = try await client
            .from("review_images")
            .insert(imageRow)
            .execute()
    }
    
    func fetchReviewImage(forReviewId reviewId: Int) async throws -> ReviewImageRow? {
        let rows: [ReviewImageRow] = try await client
            .from("review_images")
            .select("review_id, url, path, created_at")
            .eq("review_id", value: reviewId)
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value

        return rows.first
    }


}
