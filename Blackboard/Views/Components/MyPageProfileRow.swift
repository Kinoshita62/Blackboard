//
//  MyPageProfileRow.swift
//  Blackboard
//
//  Created by USER on 2024/10/08.
//

import SwiftUI

struct MyPageProfileRow: View {
    
    var title = ""
    var value = ""
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(value)
                .font(.subheadline)
            Spacer()
        }
    }
}

#Preview {
    MyPageProfileRow(title: "年齢", value: "20代")
}
