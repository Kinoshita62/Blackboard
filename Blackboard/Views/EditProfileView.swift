//
//  EditProfileView.swift
//  Blackboard
//
//  Created by USER on 2024/10/07.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State var name = ""
    @State var age: AgeGroup = .teens
    @State var sex: Gender = .male
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("変更") {
                        Task {
                            guard let currentUser = authViewModel.currentUser else {
                                print("カレントユーザーが見つかりません")
                                return
                            }
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
        VStack(spacing: 16) {
            //PhotoPicker
            PhotosPicker(selection: $authViewModel.selectedImage) {
                Group {
                    if let uiImage = authViewModel.profileImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    } else if let urlString = authViewModel.currentUser?.photoUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                                .frame(width: 48, height: 48 )
                        }
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .foregroundStyle(.gray)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    }
                }
            }
            
            //InputField
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
            } else {
                Task {
                    await authViewModel.fetchCurrentUser()
                }
            }
        }
    }
}

