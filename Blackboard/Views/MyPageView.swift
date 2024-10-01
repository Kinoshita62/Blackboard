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
    
    var body: some View {
        VStack {
                Capsule()
                    .foregroundStyle(.white)
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            List {
                Section {
                    HStack(spacing: 24) {
                        Text(authViewModel.currentUser?.name ?? "ユーザーネーム")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        Text(authViewModel.currentUser?.email ?? "メールアドレス")
                            .font(.footnote)
                            .tint(.gray)
                    }
                }
                
                Section {
                    VStack {
                        
                    }
                }
                
                Section {
                    VStack(spacing: 8) {
                        Button {
                            authViewModel.logout()
                        } label: {
                            MyPageRow(iconName: "arrow.left.circle.fill", label: "ログアウト", tintColor: .red)
                        }
                        
                        Divider()
                        
                        Button {
                            showDeleteAlert = true
                        } label: {
                            MyPageRow(iconName: "xmark.circle.fill", label: "アカウント削除", tintColor: .red)
                        }
                        .alert("アカウント削除", isPresented: $showDeleteAlert) {
                            Button("キャンセル") {}
                            Button("削除") { Task { await authViewModel.deleteAccount() } }
                        } message: {
                            Text("アカウントを削除しますか？")
                        }
                    }
                }
            }
            
        }
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
            .environmentObject(AuthViewModel())
    }
}
