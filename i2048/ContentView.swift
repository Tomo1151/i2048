//
//  ContentView.swift
//  i2048
//
//  Created by Tomoyasu on 2025/06/17.
//

import SwiftUI

struct ContentView: View {
    @State private var BOARD: [Int?] = [
        4, nil, nil, nil,
        nil, nil, nil, 2,
        nil, nil, nil, nil,
        nil, nil, nil, nil,
    ]
    
    let BOARD_SIZE: Int = 4
    
    var body: some View {
        ZStack {
            Color("body_bg").edgesIgnoringSafeArea(.all)
            
            VStack {
                ForEach(0..<BOARD_SIZE, id: \.self) { i in
                    HStack {
                        ForEach(0..<BOARD_SIZE, id: \.self) { j in
                            Text("\(BOARD[i * BOARD_SIZE + j] != nil ? "\(BOARD[i * BOARD_SIZE + j]!)" : "")")
                                .frame(width: 50, height: 50, alignment: .center)
                                .padding(12)
                                .background(Color("cell_bg_empty"))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: .brown, radius: 3, x: 2, y: 2)
                                .fontWeight(.heavy)
                        }
                    }
                }
            }
            .padding(10)
            .background(Color("board_bg"))
            .fontDesign(.monospaced)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }
}

#Preview {
    ContentView()
}
