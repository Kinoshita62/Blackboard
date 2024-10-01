//
//  AuthViewModel.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import FirebaseStorage

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserModel?
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    func createAccount(email: String, password: String, name: String, age: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("成功: \(result.user.email)")
            self.userSession = result.user
            let newUser = UserModel(id: result.user.uid, name: name, email: email, age: age)
            try await Firestore.firestore().collection("users").document(result.user.uid).setData([
                        "name": name,
                        "email": email,
                        "age": age,
                        "id": result.user.uid
                    ])
            await fetchCurrentUser()
        }catch {
            print("失敗: \(error.localizedDescription)")
        }
    }
    
    func resetAccount() {
        self.userSession = nil
        self.currentUser = nil
    }
    
    func login(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("ログイン成功: \(result.user.email)")
            self.userSession = result.user
            print("\(self.userSession): \(self.userSession?.email)")
            await fetchCurrentUser()
        } catch {
            print("ログイン失敗: \(error.localizedDescription)")
        }
    }
    
    func logout(){
        do {
            try Auth.auth().signOut()
            print("ログアウト成功")
            self.resetAccount()
        } catch {
            print("ログアウト失敗 :\(error.localizedDescription)")
        }
    }
    
    func fetchCurrentUser() async {
        
        guard let uid = self.userSession?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: UserModel.self)
            print("カレントユーザー取得成功: \(self.currentUser)")
        } catch {
            print("カレントユーザー取得失敗: \(error.localizedDescription)")
        }
    }
}
