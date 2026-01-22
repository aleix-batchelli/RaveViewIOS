//
//  Follow.swift
//  RaveView
//
//  Created by Aniol Vergés Herrera on 22/1/26.
//

import Foundation

struct Follow: Codable {
    let follower_id: UUID
    let following_id: UUID
    let created_at: Date
}
