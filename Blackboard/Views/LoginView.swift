//
//  LoginView.swift
//  Blackboard
//
//  Created by USER on 2024/09/30.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerImage
                
                loginForm
                
                Spacer()
                
                navigateToRegistration
            }
            .padding(.top, 16)
            .padding(.horizontal)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

extension LoginView {
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
    
    private var loginForm: some View {
        VStack(spacing: 16) {
            InputField(text: $email, label: "メールアドレス", placeholder: "入力してください", keyboardType: .emailAddress)
            
            InputField(text: $password, label: "パスワード", placeholder: "半角英数字6文字以上", isSecureField: true)
            
            BasicButton(label: "ログイン", icon: "arrow.right") {
                Task {
                    await authViewModel.login(email: email, password: password)
                }
            }
        }
    }
    
    private var navigateToRegistration: some View {
        NavigationLink {
            RegistrationView()
        } label: {
            HStack {
                Text("まだアカウントをお持ちでない方")
                Text("会員登録")
                    .fontWeight(.bold)
            }
            .foregroundStyle(Color(.darkGray))
        }
    }
}
