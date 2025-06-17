//
//  ContentView.swift
//  i2048
//
//  Created by Tomoyasu on 2025/06/17.
//

import SwiftUI

struct Cell {
    var id: Int
    var number: Int
    var x: Int
    var y: Int
}


struct ContentView: View {
//    盤面のサイズ
    let BOARD_SIZE: Int = 4
    let BOARD_PADDING: CGFloat = 10
    let CELL_SIZE: CGFloat = 50
    let CELL_PADDING: CGFloat = 12
    let CELL_TEXT_SIZE: CGFloat = 32
    
//    次に割り振るID (連番)
    @State private var generatedId: Int = 0
    
//    盤面チェック用配列
    @State private var board: [Int?] = [
        4, nil, nil, nil,
        nil, nil, nil, 2,
        nil, nil, nil, nil,
        nil, nil, nil, nil,
    ]
    
//    既に数字のあるマスの一覧 (アニメーション用)
    @State private var Cells: [Cell] = [
        Cell(id: 0, number: 2, x: 0, y: 0),
        Cell(id: 1, number: 4, x: 1, y: 0),
        Cell(id: 2, number: 8, x: 2, y: 0),
        Cell(id: 3, number: 16, x: 3, y: 0),
        Cell(id: 4, number: 32, x: 0, y: 1),
        Cell(id: 5, number: 64, x: 1, y: 1),
        Cell(id: 6, number: 128, x: 2, y: 1),
        Cell(id: 7, number: 256, x: 3, y: 1),
        Cell(id: 8, number: 512, x: 0, y: 2),
        Cell(id: 9, number: 1024, x: 1, y: 2),
        Cell(id: 10, number: 2048, x: 2, y: 2),
    ]
    
//    メインビュー
    var body: some View {
        ZStack {
//            背景色
            Color("body_bg").edgesIgnoringSafeArea(.all)
            
//            ゲーム画面
            VStack {
                ForEach(0..<BOARD_SIZE, id: \.self) { i in
                    HStack {
                        ForEach(0..<BOARD_SIZE, id: \.self) { j in
                            Text("")
                                .frame(width: CELL_SIZE, height: CELL_SIZE, alignment: .center)
                                .padding(CELL_PADDING)
                                .background(Color("cell_bg_empty"))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: .brown, radius: 3, x: 2, y: 2)
                                .fontWeight(.heavy)
                        }
                    }
                }
            }
            .padding(BOARD_PADDING)
            .background(Color("board_bg"))
            .fontDesign(.monospaced)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            
            ForEach(0..<Cells.count, id: \.self) { i in
                let cell = Cells[i]
                let center = Double(BOARD_SIZE - 1) / 2
                let posX = -((CELL_SIZE + CELL_TEXT_SIZE) / 2) * CGFloat(center - Double(cell.x)) * 2
                let posY = -((CELL_SIZE + CELL_TEXT_SIZE) / 2) * CGFloat(center - Double(cell.y)) * 2
                
                ZStack {
                    Text(String(cell.number))
//                    .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)
                    .frame(width: CELL_SIZE, height: CELL_SIZE, alignment: .center)
                    .padding(CELL_PADDING)
                    .foregroundColor(cell.number  < 8 ? Color("cell_text_black") : Color("cell_text_white"))
                    .background(Color("cell_bg_\(cell.number)"))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .fontWeight(.heavy)
                    .font(.system(size: 32))
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
                    .offset(x: posX, y: posY)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
