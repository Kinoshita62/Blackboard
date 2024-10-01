//
//  UserModel.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import Foundation

struct UserModel: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let age: String
    var photoUrl: String?
    var message: String?
}

