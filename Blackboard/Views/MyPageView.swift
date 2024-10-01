//
//  MyPageView.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import SwiftUI

struct MyPageView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
                    HStack(spacing: 4) {
                        Text(authViewModel.currentUser?.name ?? "")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text(authViewModel.currentUser?.email ?? "")
                            .font(.footnote)
                            .tint(.gray)
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
