//
//  MyPageRow.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import SwiftUI

struct MyPageRow: View {
    
    let iconName: String
    let label: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .imageScale(.large)
                .foregroundStyle(tintColor)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.black)
            Spacer()
        }
    }
}

#Preview {
    MyPageRow(iconName: "person.fill", label: "label", tintColor: .red)
}
