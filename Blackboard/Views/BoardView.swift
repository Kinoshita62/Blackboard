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
        VStack {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "lessthan")
                            .foregroundStyle(.black)
                            .font(.title2)
                    }

                    Text(board.name)
                        .font(.largeTitle)
                        .padding()
                    Spacer()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(boardViewModel.messages) { message in
                            HStack {
                                if message.senderName != authViewModel.currentUser?.name {
                                    Text(message.content)
                                        .font(.body)
                                        .padding(5)
                                        .background(.white)
                                        .cornerRadius(8)
                                    VStack {
                                        Text(formatDate(message.timestamp))
                                           
                                        Text(message.senderName)
                                            
                                    }
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                    Spacer()
                                } else {
                                    Spacer()
                                    Text(message.content)
                                        .font(.body)
                                        .padding(5)
                                        .background(.white)
                                        .cornerRadius(8)
                                    VStack {
                                        Text(formatDate(message.timestamp))

                                        Text(message.senderName)
                                            
                                    }
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
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
            .padding(.horizontal)
            .background(.green)
            
            VStack {
                
                HStack {
                    TextField("入力してください", text: $newMessage)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        if !newMessage.isEmpty {
                            Task {
                                let senderName = authViewModel.currentUser?.name ?? "不明なユーザー"
                                await boardViewModel.postMessage(boardId: board.id ?? "", content: newMessage, senderName: senderName)
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
            
            .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    BoardView(board: BoardModel(id: "sampleID", name: "Sample Board", createDate: Date(), postCount: 0))
        .environmentObject(AuthViewModel())
}
