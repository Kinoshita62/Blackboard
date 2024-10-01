//
//  ContentView.swift
//  Blackboard
//
//  Created by USER on 2024/09/30.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
