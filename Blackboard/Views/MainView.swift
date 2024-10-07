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
    @State private var filteredBoards = [BoardModel]()
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                header
                
                searchFilterArea
                
                boardListArea
                
            }
            .padding(.horizontal)
            .sheet(isPresented: $isShowingAddBoardView) {
                AddBoardView(boardViewModel: boardViewModel, isShowingAddBoardView: $isShowingAddBoardView, onAddCompletion: {
                    // 掲示板が追加された後にリストを更新する
                    boardViewModel.fetchBoards {
                        // fetchBoardsの完了後にフィルタリングを行う
                        self.filteredBoards = boardViewModel.getFilteredBoards(searchText: searchText, isSortedByPostCount: isSortedByPostCount)
                    }
                })
                
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                if let _ = authViewModel.userSession {
                    boardViewModel.fetchBoards {
                        // fetchBoardsの完了後にフィルタリングを行う
                        self.filteredBoards = boardViewModel.getFilteredBoards(searchText: searchText, isSortedByPostCount: isSortedByPostCount)
                    }
                }
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
                if let urlString = authViewModel.currentUser?.photoUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Image(systemName: "person.circle")
                                .resizable()
                                .foregroundStyle(.gray)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.circle")
                                .resizable()
                                .foregroundStyle(.gray)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        @unknown default:
                            Image(systemName: "person.circle")
                                .resizable()
                                .foregroundStyle(.gray)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        }
                    }
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .foregroundStyle(.gray)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                }
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
                    .onChange(of: searchText) {
                        
                        self.filteredBoards = boardViewModel.getFilteredBoards(searchText: searchText, isSortedByPostCount: isSortedByPostCount)
                    }
            }
            
            HStack {
                
                Spacer()
                
                Button(action: {
                    isSortedByPostCount = false
                    self.filteredBoards = boardViewModel.getFilteredBoards(searchText: searchText, isSortedByPostCount: isSortedByPostCount)
                }, label: {
                    Text("日付順")
                        .foregroundStyle(isSortedByPostCount ? Color.gray : Color.black)
                })
                Text("/")
                Button(action: {
                    isSortedByPostCount = true
                    self.filteredBoards = boardViewModel.getFilteredBoards(searchText: searchText, isSortedByPostCount: isSortedByPostCount)
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
                                    .padding(.top, 40)
                                Text("投稿数 \(board.postCount)")
                                Spacer()
                                Text("作成日" + formatDate(board.createDate))
                                    .padding(.bottom)
                                
                            }
                            .foregroundColor(.black)
                            .frame(width: 150, height: 150)
                            .background(.green)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
