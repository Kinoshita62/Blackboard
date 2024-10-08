//
//  PickerField.swift
//  Blackboard
//
//  Created by USER on 2024/09/30.
//
import SwiftUI

struct PickerComponent<T: Hashable & CaseIterable & RawRepresentable>: View where T.AllCases: RandomAccessCollection, T.RawValue == String {
    let title: String
    @Binding var selection: T
    
    var body: some View {
        
        HStack {
            Text(title)
                .fontWeight(.semibold)
                .font(.footnote)
            Spacer()
            Picker(title, selection: $selection) {
                ForEach(T.allCases, id: \.self) { item in
                    Text(item.rawValue)
                        .tag(item)
                }
            }
        }
    }
}
