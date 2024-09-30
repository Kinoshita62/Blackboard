//
//  LoginView.swift
//  Blackboard
//
//  Created by USER on 2024/09/30.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
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
                    InputField(text: $email, label: "メールアドレス", placeholder: "入力してください", keyboardType: .emailAddress)
                    
                    InputField(text: $password, label: "パスワード", placeholder: "半角英数字6文字以上", isSecureField: true)

                    Button(action: {
                        
                    }, label: {
                        Text("ログイン")
                            .foregroundStyle(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                            .background(Color(.green))
                            .clipShape(Capsule())
                    })
                    
                    Spacer()
                    
                    NavigationLink {
                        RegistrationView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        HStack {
                            Text("まだアカウントをお持ちでない方")
                            Text("会員登録")
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
}


#Preview {
    LoginView()
}
