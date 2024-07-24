//
//  DBUser.swift
//  MenuInspector
//
//  Created by Kiss Roland on 12/04/2024.
//

import Foundation

struct DBUser: Codable{
    
    let userId: String
    let name: String?
    let height: String?
    let weight: String?
    let birthDate: Date?
    let gender: String?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case height
        case weight
        case birthDate = "birth_date"
        case gender
        case email
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
    }
}
