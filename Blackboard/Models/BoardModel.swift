//
//  BoardModel.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import Foundation
import FirebaseFirestore

struct BoardModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var createDate: Date
    var postCount: Int
}
