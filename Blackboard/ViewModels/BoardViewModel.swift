//
//  BoardViewModel.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import Foundation
import Firebase
import FirebaseFirestore

class BoardViewModel: ObservableObject {
    @Published var boards = [BoardModel]()
    @Published var messages = [MessageModel]()
    
    @MainActor
    func fetchBoards() {
        Firestore.firestore().collection("boards").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("エラーが発生しました: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("ドキュメントが見つかりません")
                return
            }
            
            self.boards = documents.compactMap { queryDocumentSnapshot in
                do {
                    var board = try queryDocumentSnapshot.data(as: BoardModel.self)
                    let boardId = queryDocumentSnapshot.documentID
                    Firestore.firestore().collection("boards").document(boardId).collection("messages").getDocuments { (snapshot, error) in
                        if let error = error {
                            print("投稿数の取得に失敗しました: \(error.localizedDescription)")
                            return
                        }
            
                        board.postCount = snapshot?.documents.count ?? 0
                        DispatchQueue.main.async {
                            if let index = self.boards.firstIndex(where: { $0.id == boardId }) {
                                self.boards[index] = board
                            }
                        }
                    }
                    return board
                } catch {
                    print("データのデコードに失敗しました: \(error.localizedDescription)")
                        return nil
                }
            }
        }
    }
    
    @MainActor
    func postMessage(boardId: String, content: String, senderName: String) async {
        let message = MessageModel(id: nil, content: content, senderName: senderName, timestamp: Date())
        
        do {
            let messageData = try Firestore.Encoder().encode(message)
            try await Firestore.firestore().collection("boards").document(boardId).collection("messages").addDocument(data: messageData)
            print("メッセージ投稿成功")
        } catch {
            print("メッセージ投稿失敗: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func addBoard(name: String) async {
        let newBoard = BoardModel(id: nil, name: name, createDate: Date(), postCount: 0)
        do {
            let boardData = try Firestore.Encoder().encode(newBoard)
            try await Firestore.firestore().collection("boards").addDocument(data: boardData)
            print("掲示板追加成功")
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
}
