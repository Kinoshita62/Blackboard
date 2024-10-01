//
//  MainView.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                
                HStack {
                    NavigationLink {
                        MyPageView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    Rectangle()
                        .frame(width: 144, height: 48)
                    Spacer()
                    Circle()
                        .frame(width: 48, height: 48)
                }
                
                HStack(spacing: 16) {
                    Rectangle()
                        .frame(width: 144, height: 144)
                    Rectangle()
                        .frame(width: 144, height: 144)
                }
                
                HStack(spacing: 16) {
                    Rectangle()
                        .frame(width: 144, height: 144)
                    Rectangle()
                        .frame(width: 144, height: 144)
                }
                
                HStack(spacing: 16) {
                    Rectangle()
                        .frame(width: 144, height: 144)
                    Rectangle()
                        .frame(width: 144, height: 144)
                }
                
            }
            .padding(.horizontal)
        }
        
    }
}

#Preview {
    MainView()
}
