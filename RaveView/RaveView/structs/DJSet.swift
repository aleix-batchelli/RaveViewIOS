//
//  DJSet.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 9/1/26.
//

struct DJSet { // Renamed from Set to DJSet
    var id: Int
    var name: String
    var auth: String
    var duration: Int
    var image: String
    var reviews: [Review] // Assuming you have a Review struct defined elsewhere
}
