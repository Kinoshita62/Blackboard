//
//  DefaultImageIcon.swift
//  Blackboard
//
//  Created by USER on 2024/10/08.
//
import SwiftUI

struct DefaultImageIcon: View {
    var body: some View {
        Image(systemName: "person.circle")
            .resizable()
            .foregroundStyle(.gray)
            .aspectRatio(contentMode: .fill)
            .frame(width: 35, height: 35)
            .clipShape(Circle())
    }
}

#Preview {
    DefaultImageIcon()
}

