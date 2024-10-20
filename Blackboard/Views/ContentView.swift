//
//  ContentView.swift
//  Blackboard
//
//  Created by USER on 2024/09/30.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.userSession != nil {
                MainView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
