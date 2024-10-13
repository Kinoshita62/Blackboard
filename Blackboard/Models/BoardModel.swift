//
//  BoardModel.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import Foundation
import FirebaseFirestore

struct BoardModel: Identifiable, Codable {
    var id: String?
    var name: String
    var createDate: Date
    var postCount: Int
    var creatorID: String
}
