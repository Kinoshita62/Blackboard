//
//  BoardView.swift
//  Blackboard
//
//  Created by USER on 2024/10/02.
//

import SwiftUI

struct BoardView: View {
    
    var board: BoardModel
    @State private var newMessage = ""
    @ObservedObject var boardViewModel = BoardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        NavigationStack {
            VStack {
                messageArea
                imputArea
            }
            .navigationTitle(board.name)
            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("＜戻る") {
                        dismiss()
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
    }
}

#Preview {
    BoardView(board: BoardModel(id: "sampleID", name: "Sample Board", createDate: Date(), postCount: 0))
        .environmentObject(AuthViewModel())
}

extension BoardView {
    private var messageArea: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(boardViewModel.messages) { message in
                        HStack {
                            if message.senderID != authViewModel.currentUser?.id {
                                senderImageView(senderPhotoUrl: message.senderPhotoUrl)
                                Text(message.content)
                                    .font(.body)
                                    .padding(5)
                                    .background(.white)
                                    .cornerRadius(8)
                                Text(formatDate(message.timestamp))
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                Spacer()
                            } else {
                                Spacer()
                                
                                
                                Text(formatDate(message.timestamp))
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                Text(message.content)
                                    .font(.body)
                                    .padding(5)
                                    .background(.white)
                                    .cornerRadius(8)
                                senderImageView(senderPhotoUrl: message.senderPhotoUrl)
                            }
                        }
                    }
                }
            }
            .onAppear {
                boardViewModel.fetchMessages(boardId: board.id ?? "")
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.green)
    }
    
    private var imputArea: some View {
        VStack {
            HStack {
                TextField("入力してください", text: $newMessage)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    if !newMessage.isEmpty {
                        Task {
                            let senderName = authViewModel.currentUser?.name ?? "不明なユーザー"
                            await boardViewModel.postMessage(boardId: board.id ?? "", content: newMessage, senderName: senderName, authViewModel: authViewModel)
                            newMessage = ""
                        }
                    }
                }, label: {
                    Text("送信")
                        .padding(.vertical, 7)
                        .padding(.horizontal, 10)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                })
            }
            .padding(.horizontal)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
