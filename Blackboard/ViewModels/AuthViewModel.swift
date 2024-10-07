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
    @Published var selectedImage: PhotosPickerItem? {
        didSet {
            Task { await loadImage() }
        }
    }
    @Published var profileImage: UIImage?
    
    init() {
        self.userSession = Auth.auth().currentUser
        print("ログインユーザー: \(self.userSession?.email)")
        Task {
            await self.fetchCurrentUser()
        }
    }
    
    @MainActor
    func createAccount(email: String, password: String, name: String, age: AgeGroup, sex: Gender) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("成功: \(result.user.email)")
            DispatchQueue.main.async {
                self.userSession = result.user
            }
            let newUser = UserModel(id: result.user.uid, name: name, email: email, age: age, sex: sex)
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
        self.profileImage = nil
    }
    
    @MainActor
    func login(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("ログイン成功: \(result.user.email)")
            self.userSession = result.user
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
        guard let uid = self.userSession?.uid else {
            print("ユーザーのUIDが見つかりません")
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            if let data = snapshot.data() {
                self.currentUser = try snapshot.data(as: UserModel.self)
                print("カレントユーザー取得成功: \(self.currentUser?.name ?? "名前なし")")
            } else {
                print("ユーザーのドキュメントが見つかりません: UID = \(uid)")
            }
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
    
    @MainActor
    private func loadImage() async {
        guard let image = selectedImage else { return }
        do {
            guard let data = try await image.loadTransferable(type: Data.self) else { return }
            self.profileImage = UIImage(data: data)
        } catch {
            print("参照データロード失敗: \(error.localizedDescription)")
        }
        
    }
    
    func updateUserProfile(withID id: String, name: String, age: AgeGroup, sex: Gender, message: String)  async {
        var data: [AnyHashable: Any] = [
            "name": name,
            "age": age.rawValue,
            "sex": sex.rawValue,
            "message": message
        ]
        
        if let urlString = await uploadImage() {
            data["photoUrl"] = urlString
        }
        
        do {
            try await Firestore.firestore().collection("users").document(id).updateData(data)
            print("プロフィール更新成功")
            await self.fetchCurrentUser()
        } catch {
            print("プロフィール更新失敗: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func uploadImage() async -> String? {
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "/user_images/\(filename)")
        
        guard let uiImage = self.profileImage else { return nil }
        guard let imageData = uiImage.jpegData(compressionQuality: 0.5) else { return nil }
        
        do {
            let _ = try await storageRef.putDataAsync(imageData)
            print("画像アップロード成功")
            let urlString = try await storageRef.downloadURL().absoluteString
            return urlString
        } catch {
            print("画像アップロード失敗: \(error.localizedDescription)")
            return nil
        }
    }
}
