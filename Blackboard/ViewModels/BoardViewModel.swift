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
                        var board = try document.data(as: BoardModel.self)
                        let boardId = document.documentID
                        let snapshot = try await Firestore.firestore().collection("boards").document(boardId).collection("messages").getDocuments()
                        
                        board.postCount = snapshot.documents.count
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
        let message = MessageModel(
            id: UUID().uuidString,
            senderID: senderID,
            content: content,
            senderName: senderName,
            senderPhotoUrl: senderPhotoUrl,
            timestamp: Date()
        )
        
        do {
            let messageData = try Firestore.Encoder().encode(message)
            try await Firestore.firestore().collection("boards").document(boardId).collection("messages").addDocument(data: messageData)
            print("メッセージ投稿成功")
        } catch {
            print("メッセージ投稿失敗: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func addBoard(name: String, completion: @escaping () -> Void) async {
        let newBoard = BoardModel(id: nil, name: name, createDate: Date(), postCount: 0)
        do {
            let boardData = try Firestore.Encoder().encode(newBoard)
            try await Firestore.firestore().collection("boards").addDocument(data: boardData)
            print("掲示板追加成功")
            fetchBoards {
                completion()
            }
        } catch {
            print("掲示板追加失敗: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchMessages(boardId: String) {
        Firestore.firestore().collection("boards").document(boardId).collection("messages")
            .order(by: "timestamp", descending: false)
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
        
        var boards: [BoardModel] = self.boards
        
        if !searchText.isEmpty {
            boards = boards.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if isSortedByPostCount {
            return boards.sorted { $0.postCount > $1.postCount }
        } else {
            return boards.sorted { $0.createDate > $1.createDate }
        }
    }
}
