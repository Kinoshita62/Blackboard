//
//  MyPageView.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import SwiftUI

struct MyPageView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showDeleteAlert = false
    @State private var showEditProfileView = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    accountProfileArea
                    
                    accountSettingArea
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle("マイページ")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("＜戻る") {
                        dismiss()
                    }
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(.primary)
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
            .environmentObject(AuthViewModel())
    }
}

extension MyPageView {
    private var accountProfileArea: some View {
        VStack(spacing: 32) {
            accountName
            accountProfile
        }
        .padding()
        .background(.white)
        .cornerRadius(10)
    }
    
    private var accountSettingArea: some View {
        VStack(spacing: 16) {
            NavigationLink(destination: EditProfileView()) {
                MyPageRow(iconName: "square.and.pencil.circle.fill", label: "プロフィール変更", tintColor: .red)
            }
            .padding()
            .background(.white)
            .cornerRadius(10)
            
            Button {
                authViewModel.logout()
            } label: {
                MyPageRow(iconName: "arrow.left.circle.fill", label: "ログアウト", tintColor: .red)
            }
            .padding()
            .background(.white)
            .cornerRadius(10)
            
            Button {
                showDeleteAlert = true
            } label: {
                MyPageRow(iconName: "xmark.circle.fill", label: "アカウント削除", tintColor: .red)
            }
            .alert("アカウント削除", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("削除", role: .destructive) { Task { await authViewModel.deleteAccount() } }
            } message: {
                Text("アカウントを削除しますか？")
            }
            .padding()
            .background(.white)
            .cornerRadius(10)
        }
    }
    
    private var accountName: some View {
        HStack(spacing: 16) {
            if let urlString = authViewModel.currentUser?.photoUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .foregroundStyle(.gray)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            }
            Text(authViewModel.currentUser?.name ?? "")
                .font(.subheadline)
                .fontWeight(.bold)
            
            Spacer()
        }
    }
    
    private var accountProfile: some View {
        VStack(spacing: 16) {
            MyPageProfileRow(title: "年齢", value: authViewModel.currentUser?.age.rawValue ?? "未設定")
            MyPageProfileRow(title: "性別", value: authViewModel.currentUser?.sex.rawValue ?? "未設定")
            MyPageProfileRow(title: "メッセージ", value: authViewModel.currentUser?.message ?? "未設定")
        }
    }
}
