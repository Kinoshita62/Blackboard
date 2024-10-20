//
//  BoardViewModel.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore

class BoardViewModel: ObservableObject {
    @Published var boards = [BoardModel]()
    @Published var messages = [MessageModel]()
    @Published var filteredBoards = [BoardModel] ()
    
    @MainActor
    func fetchBoards(completion: @escaping () -> Void) {
        Firestore.firestore().collection("boards").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("エラーが発生しました: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("ドキュメントが見つかりません")
                completion()
                return
            }
            
            Task {
                var updatedBoards = [BoardModel]()
                for document in documents {
                    do {
                        var board = try document.data(as: BoardModel.self) //BoardModel型にデコード
                        let boardId = document.documentID
                        board.id = boardId
                        let snapshot = try await Firestore.firestore().collection("boards").document(boardId).collection("messages").getDocuments() //サブコレクションからの取得
                        
                        board.postCount = snapshot.documents.count
                        
                        let userSnapshot = try await Firestore.firestore().collection("users").document(board.creatorID).getDocument()
                        if let userData = userSnapshot.data(), let creatorName = userData["name"] as? String {
                            board.creatorName = creatorName
                        }
                        
                        updatedBoards.append(board)
                    } catch {
                        print("データのデコードに失敗しました: \(error.localizedDescription)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.boards = updatedBoards
                    completion() // データ取得後にクロージャを呼び出す
                }
            }
        }
    }
    
    @MainActor
    func postMessage(boardId: String, content: String, senderName: String, authViewModel: AuthViewModel) async {
        guard let senderID = authViewModel.currentUser?.id else {
            print("ユーザーがログインしていません")
            return
        }
        let senderPhotoUrl = authViewModel.currentUser?.photoUrl
        // UUIDを使って一意のIDを生成
        var message = MessageModel(
            id: nil,
            senderID: senderID,
            content: content,
            senderName: senderName,
            senderPhotoUrl: senderPhotoUrl,
            timestamp: Date()
        )
        
        do {
            let ref = try await Firestore.firestore().collection("boards").document(boardId).collection("messages").addDocument(from: message)
            message.id = ref.documentID
            try await Firestore.firestore().collection("boards").document(boardId).collection("messages").document(ref.documentID).updateData(["id": message.id!])
            print("メッセージ投稿成功")
        } catch {
            print("メッセージ投稿失敗: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func addBoard(name: String, authViewModel: AuthViewModel, completion: @escaping () -> Void) async -> BoardModel? {
        guard let creatorID = authViewModel.currentUser?.id else {
            print("ユーザーがログインしていません")
            return nil
        }
        let newBoard = BoardModel(id: nil, name: name, createDate: Date(), postCount: 0, creatorID: creatorID) //IDは自動で生成
        do {
            let ref = try await Firestore.firestore().collection("boards").addDocument(from: newBoard) // 追加ドキュメントの参照
            let documentID = ref.documentID
            print("新しい掲示板ID: \(documentID)")
            
            var updatedBoard = newBoard
            updatedBoard.id = documentID
            completion()
            return updatedBoard
            
        } catch {
            print("掲示板追加失敗: \(error.localizedDescription)")
            return nil
        }
    }
    
    @MainActor
    func fetchMessages(boardId: String) {
        Firestore.firestore().collection("boards").document(boardId).collection("messages")
            .order(by: "timestamp", descending: false) //古い順に並べる
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("メッセージの取得に失敗しました: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("ドキュメントが見つかりません")
                    return
                }
                
                self.messages = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: MessageModel.self)
                }
            }
    }
    
    func getFilteredBoards(searchText: String, isSortedByPostCount: Bool) -> [BoardModel] {
        
        var boards: [BoardModel] = self.boards //self.boardsは共有データのため、コピーをローカル変数として定義
        
        if !searchText.isEmpty {
            boards = boards.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if isSortedByPostCount {
            return boards.sorted { $0.postCount > $1.postCount }
        } else {
            return boards.sorted { $0.createDate > $1.createDate }
        }
    }
    
    @MainActor
    func deleteBoard(boardId: String, creatorID: String, authViewModel: AuthViewModel, completion: @escaping () -> Void) async {
        guard let currentUserID = authViewModel.currentUser?.id else {
            print("ユーザーがログインしていません")
            return
        }
        if currentUserID != creatorID {
            print("掲示板の作成者のみが削除できます")
            return
        }
        do {
            try await Firestore.firestore().collection("boards").document(boardId).delete()
            print("掲示板削除成功")
            fetchBoards {
                completion()
            }
        } catch {
            print("掲示板削除失敗: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deleteMessage(boardId: String, messageId: String, senderID: String, authViewModel: AuthViewModel) async {
        guard let currentUserID = authViewModel.currentUser?.id else {
            print("ユーザーがログインしていません")
            return
        }
        if currentUserID != senderID {
            print("メッセージの送信者のみが削除できます")
            return
        }
        guard !messageId.isEmpty else {
            print("メッセージIDが無効です")
            return
        }
        do {
            let messageRef = Firestore.firestore().collection("boards").document(boardId).collection("messages").document(messageId)
            let documentSnapshot = try await messageRef.getDocument()
            
            if documentSnapshot.exists {
                try await messageRef.delete()
                print("メッセージ削除成功")
            } else {
                print("メッセージが見つかりません")
            }
        } catch {
            print("メッセージ削除失敗: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func updateBoardDescription(boardId: String, newDescription: String, authViewModel: AuthViewModel) async {
        guard let currentUserID = authViewModel.currentUser?.id else {
            print("ユーザーがログインしていません")
            return
        }
        
        let boardRef = Firestore.firestore().collection("boards").document(boardId)
        
        do {
            let documentSnapshot = try await boardRef.getDocument()
            
            let board = try documentSnapshot.data(as: BoardModel.self)
            
            if board.creatorID != currentUserID {
                print("掲示板の作成者のみが説明文を更新できます")
                return
            }
            
            try await boardRef.updateData(["boardDescription": newDescription])
            print("説明文の更新に成功しました")
            
            if let index = self.boards.firstIndex(where: { $0.id == boardId }) {
                self.boards[index].boardDescription = newDescription
            }
            
        } catch {
            print("説明文の更新に失敗しました: \(error.localizedDescription)")
        }
    }
    
}
