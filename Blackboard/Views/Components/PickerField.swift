//
//  PickerField.swift
//  Blackboard
//
//  Created by USER on 2024/09/30.
//


import SwiftUI

struct PickerField: View {
    
    @Binding var selection: String
    let title: String
    let ageOptions = ["10代", "20代", "30代", "40代", "50代", "60代", "70代以上"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .foregroundStyle(Color(.darkGray))
                    .fontWeight(.semibold)
                    .font(.footnote)
                Spacer()
                Picker(selection: $selection, label: Text("年齢")) {
                    ForEach(ageOptions, id: \.self) { age in
                        Text(age)
                            .tag(age)
                    }
                }
                .tint(.black)
            }
        }
    }
}

#Preview {
    PickerField(selection: .constant("10代"), title: "title")
}
