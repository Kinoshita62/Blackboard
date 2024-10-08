//
//  BoardView.swift
//  Blackboard
//
//  Created by USER on 2024/10/02.
//

import SwiftUI
import FirebaseFirestore

struct BoardView: View {
    
    var board: BoardModel
    @State private var newMessage = ""
    @ObservedObject var boardViewModel = BoardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var isInputFieldFocused: Bool
    
    @State private var isShowingSenderProfile = false
    @State private var selectedSender: UserModel?
    
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
            .overlay(
                ZStack {
                    if selectedSender != nil {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isShowingSenderProfile = false
                                selectedSender = nil
                            }
                    }
                    GeometryReader { geometry in
                        if let sender = selectedSender {
                            SenderProfileView(sender: sender)
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.6)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 10)
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2.5)
                        }
                    }
                }
            )
        }
    }
}

#Preview {
    BoardView(board: BoardModel(id: "sampleID", name: "Sample Board", createDate: Date(), postCount: 0))
        .environmentObject(AuthViewModel())
}

extension BoardView {
    private var messageArea: some View {
        ScrollViewReader { proxy in
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(boardViewModel.messages) { message in
                            messageRow(for: message)
                        }
                    }
                }
                .onAppear {
                    boardViewModel.fetchMessages(boardId: board.id ?? "")
                    scrollToLastMessage(proxy: proxy)
                }
                .onChange(of: boardViewModel.messages.count) {
                    scrollToLastMessage(proxy: proxy)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.green)
        }
        
    }
    
    private var imputArea: some View {
        VStack {
            HStack {
                messageTextField
                sendButton
            }
            .padding(.horizontal)
        }
    }
    
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let lastMessage = boardViewModel.messages.last {
            DispatchQueue.main.async {
                withAnimation {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
    
    private func sendMessage(message: String) async {
        let senderName = authViewModel.currentUser?.name ?? "不明なユーザー"
        await boardViewModel.postMessage(boardId: board.id ?? "", content: message, senderName: senderName, authViewModel: authViewModel)
    }
    
    private func messageRow(for message: MessageModel) -> some View {
        HStack {
            if message.senderID != authViewModel.currentUser?.id {
                senderImageView(senderPhotoUrl: message.senderPhotoUrl)
                    .onTapGesture {
                        // 送信者のプロファイルを取得し、表示を更新
                        getSenderProfile(senderID: message.senderID)
                    }
                Text(message.content)
                    .font(.body)
                    .padding(5)
                    .background(.white)
                    .cornerRadius(8)
                VStack {
                    Spacer()
                    Text(DateFormatterUtility.formatDate(message.timestamp))
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                }
                Spacer()
            } else {
                Spacer()
                VStack {
                    Spacer()
                    Text(DateFormatterUtility.formatDate(message.timestamp))
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                }
                Text(message.content)
                    .font(.body)
                    .padding(5)
                    .background(.white)
                    .cornerRadius(8)
                senderImageView(senderPhotoUrl: message.senderPhotoUrl)
                    .onTapGesture {
                        // 送信者のプロファイルを取得し、表示を更新
                        getSenderProfile(senderID: message.senderID)
                    }
            }
        }
        .id(message.id) // メッセージIDを使って位置を識別
    }
    
    private var messageTextField: some View {
        TextField("入力してください", text: $newMessage)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isInputFieldFocused)
    }
    
    private var sendButton: some View {
        Button(action: {
            if !newMessage.isEmpty {
                let messageToSend = newMessage
                
                newMessage = ""
                isInputFieldFocused = false
                
                Task {
                    await sendMessage(message: messageToSend)
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
    
    private func getSenderProfile(senderID: String) {
        Firestore.firestore().collection("users").document(senderID).getDocument { document, error in
            if let document = document, document.exists {
                do {
                    // ドキュメントを UserModel にデコード
                    let user = try document.data(as: UserModel.self)
                    DispatchQueue.main.async {
                        // Firestoreから取得したUserModelをselectedSenderにセット
                        self.selectedSender = user
                        self.isShowingSenderProfile = true // プロファイルの表示フラグを設定
                    }
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                }
            } else {
                print("User not found")
            }
        }
    }
}
