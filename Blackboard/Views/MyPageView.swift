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
            VStack(spacing: 32) {
                HStack(spacing: 16) {
                    if let urlString = authViewModel.currentUser?.photoUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                                .frame(width: 48, height: 48 )
                        }
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .foregroundStyle(.gray)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authViewModel.currentUser?.name ?? "")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text(authViewModel.currentUser?.email ?? "")
                            .font(.footnote)
                            .tint(.gray)
                    }
                    Spacer()
                }
                NavigationLink(destination: EditProfileView()) {
                    MyPageRow(iconName: "square.and.pencil.circle.fill", label: "プロフィール変更", tintColor: .red)
                }
                        
                Button {
                    authViewModel.logout()
                } label: {
                    MyPageRow(iconName: "arrow.left.circle.fill", label: "ログアウト", tintColor: .red)
                }
                
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
            }
        }
        .padding(.horizontal)
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
            .environmentObject(AuthViewModel())
    }
}
