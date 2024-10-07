//
//  SenderImageView.swift
//  Blackboard
//
//  Created by USER on 2024/10/06.
//

import Foundation
import SwiftUI

func senderImageView(senderPhotoUrl: String?, size: CGFloat = 30) -> some View {
    Group {
        if let photoUrl = senderPhotoUrl, let url = URL(string: photoUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
                    .frame(width: size, height: size)
            }
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .foregroundColor(.gray)
                .clipShape(Circle())
        }
    }
}
