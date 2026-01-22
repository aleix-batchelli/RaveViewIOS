//
//  User.swift
//  RaveView
//
//  Created by Aniol Vergés Herrera on 22/1/26.
//

import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let username: String
    let display_name: String?
    let avatar_url: String?
    let is_admin: Bool
    let followers_count: Int
    let following_count: Int
    let created_at: Date
}
