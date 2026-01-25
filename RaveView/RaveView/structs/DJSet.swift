//
//  DJSet.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 9/1/26.
//

import Foundation
import UIKit
import Supabase

struct DJSet:  Codable, Identifiable  {
    let id: UUID
    let title: String
    let artist_name: String
    let url: String
    let platform: String
    let duration_sec: Int?
    let uploaded_at: String?
    let thumbnail_url: String?
    let created_by: UUID
    let created_at: String
    let avg_rating: Double?
    let ratings_count: Int?
}


