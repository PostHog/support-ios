//
//  TypingView.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//

import SwiftUI

struct TypingView: View {
    @State private var input = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Typing Test").font(.title)

            TextField("Type something...", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Text("You typed: \(input)")
        }
        .padding()
    }
}
