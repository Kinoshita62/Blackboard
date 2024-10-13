//
//  SenderProfileView.swift
//  Blackboard
//
//  Created by USER on 2024/10/08.
//

import SwiftUI

struct SenderProfileView: View {
    var sender: UserModel
    
    var body: some View {
        VStack(spacing: 24) {
            senderImageArea
            
            senderProfileArea
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    let sampleSender = UserModel(
        id: "sampleID",
        name: "サンプルユーザーさん",
        email: "sample@example.com",
        age: .twenties,
        sex: .male,
        photoUrl: nil,
        message: "こんにちは！"
    )
    return SenderProfileView(sender: sampleSender)
}

extension SenderProfileView {
    private var senderImageArea: some View {
        VStack {
            if let urlString = sender.photoUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: 150, height: 150)
                }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .foregroundStyle(.gray)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            }
        }
    }
    
    private var senderProfileArea: some View {
        VStack(spacing: 12) {
            Text("名前: " + sender.name)
            Text("年齢: " + sender.age.rawValue)
            Text("性別: " + sender.sex.rawValue)
            Text("メッセージ: " + String(sender.message ?? ""))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
    }
}
