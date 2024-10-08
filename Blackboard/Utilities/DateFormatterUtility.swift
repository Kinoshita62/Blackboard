//
//  DateFormatterUtility.swift
//  Blackboard
//
//  Created by USER on 2024/10/08.
//

import Foundation

struct DateFormatterUtility {
    static func formatDate(_ date: Date, localeIdentifier: String = "ja_JP") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
