//
//  AddBoardView.swift
//  Blackboard
//
//  Created by USER on 2024/10/02.
//

import SwiftUI

struct AddBoardView: View {
    
    @ObservedObject var boardViewModel: BoardViewModel
    @Environment(\.dismiss) var dismiss
    @State private var boardName: String = ""
    @Binding var isShowingAddBoardView: Bool
    var onAddCompletion: () -> Void // 完了クロージャ
    
    var body: some View {
        VStack {
            Text("掲示板の追加")
                .font(.headline)
            TextField("10文字以内", text: $boardName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                if !boardName.isEmpty && boardName.count < 11 {
                    Task {
                        await boardViewModel.addBoard(name: boardName) {
                            onAddCompletion()
                            dismiss()
                        }
                    }
                    isShowingAddBoardView = false
                }
            }) {
                Text("追加")
                    .frame(maxWidth: .infinity)
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        
    }
}

#Preview {
    AddBoardView(boardViewModel: BoardViewModel(), isShowingAddBoardView: .constant(true), onAddCompletion: {})
}
