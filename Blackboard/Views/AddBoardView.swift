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
        VStack(spacing: 16) {
            header
            
            boardNameInputField
            
            submitButton
            
            Spacer()
        }
        .padding()
        
    }
}

#Preview {
    AddBoardView(boardViewModel: BoardViewModel(), isShowingAddBoardView: .constant(true), onAddCompletion: {})
}

extension AddBoardView {
    private var header: some View {
        Text("掲示板の追加")
            .font(.headline)
    }
    
    private var boardNameInputField: some View {
        TextField("10文字以内", text: $boardName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(boardName.count <= 10 ? Color.gray : Color.red, lineWidth: 1)
            )
    }
    
    private var submitButton: some View {
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
                .background(boardName.isEmpty || boardName.count > 10 ? Color.gray : Color.green)
                .cornerRadius(10)
        }
        .disabled(boardName.isEmpty || boardName.count > 10)
        .padding()
    }
}

