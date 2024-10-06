//
//  EditProfileView.swift
//  Blackboard
//
//  Created by USER on 2024/10/06.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State var name = ""
    @State private var age: AgeGroup = .teens
    @State private var sex: Gender = .male
    @State var message = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                editField
            }
            .navigationTitle("プロフィール変更")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("変更") {
                        Task {
                            guard let currentUser = authViewModel.currentUser else { return }
                            await authViewModel.updateUserProfile(
                                withID: currentUser.id,
                                name: name,
                                age: age,
                                sex: sex,
                                message: message)
                            dismiss()
                        }
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(AuthViewModel())
    }
}

extension EditProfileView {
    private var editField: some View {
        VStack {
            PhotosPicker(selection: $authViewModel.selectedImage) {
                Group {
                    if let uiImage = authViewModel.profileImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 200, height: 200)
                    } else if let urlString = authViewModel.currentUser?.photoUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(width: 200, height: 200)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 200, height: 200)
                        }
                    } else {
                        Image(systemName: "person.circle")
                            .font(.system(size: 100))
                            .foregroundStyle(.gray)
                        
                    }
                }
                
            }
            InputField(text: $name, label: "お名前", placeholder: "")
            PickerComponent(title: "年齢", selection: $age)
            PickerComponent(title: "性別", selection: $sex)
            InputField(text: $message, label: "メッセージ", placeholder: "入力してください")
        }
        .padding(.horizontal)
        .padding(.vertical, 32)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 1)
        }
        .padding()
        .onAppear {
            if let currentUser = authViewModel.currentUser {
                name = currentUser.name
                age = currentUser.age
                sex = currentUser.sex
                message = currentUser.message ?? ""
            }
        }
    }
}

