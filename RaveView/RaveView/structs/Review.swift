//
//  Review.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 9/1/26.
//
import Foundation

struct Review: Codable, Identifiable  {
    let id: Int
    let set_id: UUID
    let user_id: UUID
    let rating: Int
    let comment: String?
    let was_present: Bool
    let created_at: Date
    let updated_at: Date
}

extension Review {
    init(set_id: UUID, rating: Int, comment: String?, was_present: Bool) {
        self.id = 0
        self.set_id = set_id
        self.user_id = UUID()
        self.rating = rating
        self.comment = comment
        self.was_present = was_present
        self.created_at = Date()
        self.updated_at = Date() 
    }
}

