//
//  MainView.swift
//  Blackboard
//
//  Created by USER on 2024/10/01.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject private var boardViewModel = BoardViewModel()
    @State private var isShowingAddBoardView = false
    @State private var searchText = ""
    @State private var isSortedByPostCount = false
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredBoards: [BoardModel] {
        let boards: [BoardModel] //元データはそのままに
            
        if searchText.isEmpty {
            boards = boardViewModel.boards
        } else {
            boards = boardViewModel.boards.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if isSortedByPostCount {
            return boards.sorted { $0.postCount > $1.postCount }
        } else {
            return boards.sorted { $0.createDate > $1.createDate }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                HStack {
                    Text("Blackboard")
                        .font(.title)
                    Spacer()
                    NavigationLink {
                        MyPageView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.system(size: 35))
                            .foregroundStyle(.green)
                    }
                    Circle()
                        .frame(width: 35, height: 35)
                }
                
                
                HStack {
                    TextField("掲示板を検索", text: $searchText)
                        .padding(10)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                HStack {
                    
                    Spacer()
                    
                    Button(action: {
                        isSortedByPostCount = false
                    }, label: {
                        Text("日付順")
                            .foregroundStyle(isSortedByPostCount ? Color.gray : Color.blue)
                    })
                    Text("/")
                    Button(action: {
                        isSortedByPostCount = true
                    }, label: {
                        Text("投稿数順")
                            .foregroundStyle(isSortedByPostCount ? Color.blue : Color.gray)
                    })
                }
                
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredBoards) { board in
                            NavigationLink(destination: BoardView(board: board)) {
                                VStack {
                                    Text(board.name)
                                        .font(.headline)
                                        
                                    Text("投稿数 \(board.postCount)")
                                        
                                    Text("作成日" + formatDate(board.createDate))
                                        
                                }
                                .foregroundColor(.black)
                                .frame(width: 150, height: 150)
//
                                .background(Color.green)
                                .shadow(radius: 5)
                            }
                        }
                    }
                    .padding()
                }
                .onAppear {
                    boardViewModel.fetchBoards()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        isShowingAddBoardView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                        }
                        .padding()
                    }
            }
            .padding(.horizontal)
            .sheet(isPresented: $isShowingAddBoardView) {
                AddBoardView(boardViewModel: boardViewModel, isShowingAddBoardView: $isShowingAddBoardView)
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
