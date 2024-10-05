//
//  UserModel.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import Foundation

enum AgeGroup: String, Codable, CaseIterable {
    case teens = "10代"
    case twenties = "20代"
    case thirties = "30代"
    case fourties = "40代"
    case fifties = "50代"
    case sixtiesOver = "60代以上"
}

enum Gender: String, Codable, CaseIterable {
    case male = "男性"
    case female = "女性"
    case other = "その他"
}

struct UserModel: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let age: AgeGroup
    let sex: Gender
    var photoUrl: String?
    var message: String?
}

