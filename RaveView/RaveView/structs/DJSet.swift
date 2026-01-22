//
//  DJSet.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 9/1/26.
//

import Foundation

struct DJSet { // Renamed from Set to DJSet
    var id: Int
    var name: String
    var auth: String
    var duration: Int
    var image: String
    var reviews: [Review] // Assuming you have a Review struct defined elsewhere
}

struct DJSetSupabase: Codable, Identifiable {
    let id: UUID
    let title: String
    let artist_name: String
    let url: String
    let platform: String          // enum más adelante si quieres
    let duration_sec: Int?
    let uploaded_at: Date?
    let thumbnail_url: String?
    let created_by: UUID
    let created_at: Date
    let avg_rating: Double?
    let ratings_count: Int?
}

