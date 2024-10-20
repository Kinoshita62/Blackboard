//
//  BoardView.swift
//  Blackboard
//
//  Created by USER on 2024/10/02.
//

import SwiftUI
import FirebaseFirestore

struct BoardView: View {
    
    private var board: BoardModel
    @State private var newMessage = ""
    @ObservedObject var boardViewModel = BoardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var isInputFieldFocused: Bool
    
    @State private var isShowingSenderProfile = false
    @State private var selectedSender: UserModel?
    @State private var isShowingDeleteAlert = false
    @State private var messageToDelete: MessageModel?
    
    init(board: BoardModel) {
        self.board = board
    }
    
    var body: some View {
        
        NavigationStack {
            VStack {
                VStack {
                    titleArea
                    messageArea
                }
                .background(.green)
                inputArea
            }
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
        .alert(isPresented: $isShowingDeleteAlert) {
            Alert(
                title: Text("注意"),
                message: Text("「\(messageToDelete?.content ?? "メッセージ")」を削除しますか？この操作は取り消せません。"),
                primaryButton: .destructive(Text("削除する"), action: {
                    Task {
                        await boardViewModel.deleteMessage(boardId: board.id ?? "", messageId: messageToDelete?.id ?? "", senderID: messageToDelete?.senderID ?? "", authViewModel: authViewModel)
                        boardViewModel.fetchMessages(boardId: board.id ?? "")
                        messageToDelete = nil
                    }
                }),
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
    }
}

#Preview {
    BoardView(board: BoardModel(id: "sampleID", name: "Sample Board", createDate: Date(), postCount: 0, creatorID: "sampleID"))
        .environmentObject(AuthViewModel())
}

extension BoardView {
    private var titleArea: some View {
        VStack {
            HStack {
                Text(board.name)
                    .font(.title)
                    .bold()
                Spacer()
            }
            if let description = board.boardDescription, !description.isEmpty {
                HStack {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
    
    
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
                    guard let boardId = board.id else {
                        print("BoardID is nil, cannot fetch messages.")
                        return
                    }
                    boardViewModel.fetchMessages(boardId: boardId)
                    scrollToLastMessage(proxy: proxy)
                }
                .onChange(of: boardViewModel.messages.count) {
                    scrollToLastMessage(proxy: proxy)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        
    }
    
    private var inputArea: some View {
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
                
                Text(DateFormatterUtility.formatDate(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                
                
                Text(message.content)
                    .font(.body)
                    .padding(5)
                    .background(.white)
                    .cornerRadius(8)
                    .onLongPressGesture {
                        if let _ = authViewModel.currentUser?.id, message.senderID == authViewModel.currentUser?.id {
                            messageToDelete = message
                            isShowingDeleteAlert = true
                        }
                    }
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
                isInputFieldFocused = false
                
                Task {
                    await sendMessage(message: messageToSend)
                    DispatchQueue.main.async {
                        newMessage = ""
                    }
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
            if let document = document {
                do {
                    // ドキュメントを UserModel にデコード
                    let user = try document.data(as: UserModel.self)
                    DispatchQueue.main.async {
                        // Firestoreから取得したUserModelをselectedSenderにセット
                        self.selectedSender = user
                        self.isShowingSenderProfile = true
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
