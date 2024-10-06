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
                header
                
                searchFilterArea
            
                boardListArea
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

extension MainView {
    private var header: some View {
        HStack {
            Text("Blackboard")
                .font(.title)
            Spacer()
            Button(action: {
                isShowingAddBoardView.toggle()
            }, label: {
                Image(systemName: "plus")
                    .font(.system(size: 35))
                    .foregroundColor(.black)
                    .background(Color.white)
            })
            NavigationLink {
                MyPageView()
            } label: {
                Image(systemName: "person.circle")
                    .font(.system(size: 35))
                    .foregroundStyle(.black)
            }
        }
    }
    
    private var searchFilterArea: some View {
        VStack {
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
                        .foregroundStyle(isSortedByPostCount ? Color.gray : Color.black)
                })
                Text("/")
                Button(action: {
                    isSortedByPostCount = true
                }, label: {
                    Text("投稿数順")
                        .foregroundStyle(isSortedByPostCount ? Color.black : Color.gray)
                })
            }
        }
    }
    
    private var boardListArea: some View {
        ZStack {
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
                            .background(.green)
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                boardViewModel.fetchBoards()
            }     
        }
    }
}
