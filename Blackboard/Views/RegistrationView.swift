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
        VStack(spacing: 24) {
            headerImage
            
            registrationForm
                
            navigateToLogin
            }
            .padding(.top, 16)
            .padding(.horizontal)
            .navigationBarBackButtonHidden()
        }
    }

#Preview {
    RegistrationView()
}

extension RegistrationView {
    private var headerImage: some View {
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
    }
    
    private var registrationForm: some View {
        VStack(spacing: 16) {
            InputField(text: $email, label: "メールアドレス", placeholder: "入力してください")
        
            HStack {
                InputField(text: $name, label: "お名前 (8文字以内)", placeholder: "入力してください")
                if name.count > 8 {
                    Text("！")
                        .foregroundStyle(.red)
                        .bold()
                        .padding(.trailing)
                }
            }
            
            PickerComponent(title: "年齢", selection: $age)
            
            PickerComponent(title: "性別", selection: $sex)
            
            InputField(text: $password, label: "パスワード", placeholder: "半角英数字6文字以上", isSecureField: true)
            
            HStack {
                InputField(text: $confirmPassword, label: "パスワード(確認用)", placeholder: "もう一度、入力してください", isSecureField: true)
                    .textContentType(.none)
                if password.count > 0 && confirmPassword.count > 0 && password != confirmPassword {
                    Text("！")
                        .foregroundStyle(.red)
                        .bold()
                        .padding(.trailing)
                }
            }
            
            BasicButton(label: "登録", icon: "arrow.right") {
                if name.count < 9 && password == confirmPassword {
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
        }
    }
    
    private var navigateToLogin: some View {
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
}
