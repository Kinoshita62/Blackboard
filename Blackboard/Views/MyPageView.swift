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
                
            List {
                Section {
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
                    }
                }
                
                Section {
                    VStack {
                        
                    }
                }
                
                Section() {
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
