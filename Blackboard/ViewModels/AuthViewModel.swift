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
        print("ログインユーザー: \(self.userSession?.email)")
        Task {
            await self.fetchCurrentUser()
        }
    }
    
    @MainActor
    func createAccount(email: String, password: String, name: String, age: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("成功: \(result.user.email)")
            DispatchQueue.main.async {
                self.userSession = result.user
            }
            let newUser = UserModel(id: result.user.uid, name: name, email: email, age: age)
            await uploadUserData(withUser: newUser)
            await self.fetchCurrentUser()
        }catch {
            print("失敗: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func resetAccount() {
        self.userSession = nil
        self.currentUser = nil
    }
    
    @MainActor
    func login(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("ログイン成功: \(result.user.email)")
            DispatchQueue.main.async {
                self.userSession = result.user
            }
            print("\(self.userSession): \(self.userSession?.email)")
            await self.fetchCurrentUser()
        } catch {
            print("ログイン失敗: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func logout(){
        do {
            try Auth.auth().signOut()
            print("ログアウト成功")
            self.resetAccount()
        } catch {
            print("ログアウト失敗 :\(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchCurrentUser() async {
        
        guard let uid = self.userSession?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            let user = try snapshot.data(as: UserModel.self)
            DispatchQueue.main.async {
                self.currentUser = user
            }
            print("カレントユーザー取得成功: \(self.currentUser)")
        } catch {
            print("カレントユーザー取得失敗: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func uploadUserData(withUser user: UserModel) async {
        
        do {
            let userData = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(userData)
            print("データ保存成功")
        } catch {
            print("データ保存失敗: \(error.localizedDescription)")
        }
        
    }
    
    @MainActor
    func deleteAccount() async {
        guard let id = self.currentUser?.id else { return }
        do {
            try await Auth.auth().currentUser?.delete()
            try await Firestore.firestore().collection("users").document(id).delete()
            self.resetAccount()
            print("アカウント削除")
        } catch {
            print("アカウント削除失敗: \(error.localizedDescription)")
        }
    }
}
