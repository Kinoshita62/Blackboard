//
//  RegistrationView.swift
//  Blackboard
//
//  Created by USER on 2024/09/30.
//

import SwiftUI

struct RegistrationView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var name = ""
    @State private var age: AgeGroup = .teens
    @State private var sex: Gender = .male
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            ZStack {
                Image("Blackboard")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: .infinity, height: 250)
                Text("Blackboard")
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                
            }
            
            VStack(spacing: 24) {
                InputField(text: $email, label: "メールアドレス", placeholder: "入力してください")
                
                InputField(text: $name, label: "お名前 (8文字以内)", placeholder: "入力してください")
                
                PickerComponent(title: "年齢", selection: $age)
                
                PickerComponent(title: "性別", selection: $sex)
                
                
                InputField(text: $password, label: "パスワード", placeholder: "半角英数字6文字以上", isSecureField: true)
                
                InputField(text: $confirmPassword, label: "パスワード(確認用)", placeholder: "もう一度、入力してください", isSecureField: true)
                    .textContentType(.none)
                
                BasicButton(label: "登録", icon: "arrow.right") {
                    if name.count < 9 {
                        Task {
                            await authViewModel.createAccount(
                                email: email,
                                password: password,
                                name: name,
                                age: age,
                                sex: sex
                            )
                        }
                    }
                }
                
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Text("すでにアカウントをお持ちの方")
                        Text("ログイン")
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(Color(.darkGray))
                }
                
            }
            .padding(.top, 16)
            .padding(.horizontal)
            
        }
    }
}

#Preview {
    RegistrationView()
}
