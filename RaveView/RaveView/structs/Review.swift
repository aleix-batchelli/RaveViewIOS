//
//  Review.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 9/1/26.
//
import Foundation

struct Review {
    let id: String
    let title: String
    let body: String
    let author: String
    let rating: Int
}

struct ReviewSupabase: Codable, Identifiable {
    let id: Int
    let set_id: UUID
    let user_id: UUID
    let rating: Int
    let comment: String?
    let was_present: Bool
    let created_at: Date
    let updated_at: Date
}
