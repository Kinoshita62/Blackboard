//
//  MessageModel.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import Foundation
import FirebaseFirestore

struct MessageModel: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var senderID: String
    var content: String
    var senderName: String
    var senderPhotoUrl: String?
    var timestamp: Date
}
