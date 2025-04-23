//
//  ScrollingView.swift
//  support-ios
//
//  Created by Joshua Ordehi on 23/4/25.
//


import SwiftUI

struct ScrollingView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Scrolling Test").font(.title)

                ForEach(1...50, id: \.self) { i in
                    Text("Item \(i)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}
