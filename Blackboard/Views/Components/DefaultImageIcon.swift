//
//  DefaultImageIcon.swift
//  Blackboard
//
//  Created by USER on 2024/10/08.
//
import SwiftUI

struct DefaultImageIcon: View {
    
    var iconSize: CGFloat = 35
    
    var body: some View {
        Image(systemName: "person.circle")
            .resizable()
            .foregroundStyle(.gray)
            .aspectRatio(contentMode: .fill)
            .frame(width: iconSize, height: iconSize)
            .clipShape(Circle())
    }
}

#Preview {
    DefaultImageIcon()
}

