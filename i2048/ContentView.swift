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
    @State private var board: [[Int?]] = [
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
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
            
//            背景のマスの描画
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
            
//            アニメーションテスト用ボタン
//            Button("aaa") {
//                moveCellTo(id: 3, x: 3, y: 3)
//            }
            
//            数字のあるマスの描画
            ForEach(0..<Cells.count, id: \.self) { i in
                let cell = Cells[i]
                
//                盤の真ん中を取得
                let center = Double(BOARD_SIZE - 1) / 2
                
//                マスの(x, y)をもとに位置を計算
                let posX = -((CELL_SIZE + CELL_TEXT_SIZE) / 2) * CGFloat(center - Double(cell.x)) * 2
                let posY = -((CELL_SIZE + CELL_TEXT_SIZE) / 2) * CGFloat(center - Double(cell.y)) * 2
                
//                数字が存在するマスを上から描画
                ZStack {
                    Text(String(cell.number))
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
        .gesture(
            DragGesture()
                .onEnded { gesture in
//                    スワイプの検知
                    handleSwipe(translationX: gesture.translation.width, translationY: gesture.translation.height)
                }
        )
    }
    
    func generateRandomPosition() -> Int {
        return Int.random(in: 0..<BOARD_SIZE)
    }
    
    func addCell(value: Int, x: Int, y: Int) -> Void {
        board[y][x] = value
        Cells.append(Cell(id: generatedId, number: value, x: x, y: y))
        generatedId += 1
    }
    
//    アニメーション付きでマスを移動する関数
    func moveCellTo(id: Int, x: Int, y: Int) {
        if let index = Cells.firstIndex(where: { $0.id == id }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                Cells[index].x = x
                Cells[index].y = y
            }
        }
    }
    
//    画面スワイプのハンドラ
    func handleSwipe(translationX: CGFloat, translationY: CGFloat) -> Void {
        if abs(translationX) > abs(translationY) {
//                        水平方向
            if translationX > 0 {
//                            右
                print("右にスワイプされました")
                addCell(value: 2, x: generateRandomPosition(), y: generateRandomPosition())
            } else {
//                            左
                print("左にスワイプされました")
                addCell(value: 2, x: generateRandomPosition(), y: generateRandomPosition())
            }
        } else {
            if translationY > 0 {
//                            下
                print("下にスワイプされました")
                addCell(value: 2, x: generateRandomPosition(), y: generateRandomPosition())
            } else {
//                            上
                print("上にスワイプされました")
                addCell(value: 2, x: generateRandomPosition(), y: generateRandomPosition())
            }
        }
    }
}

#Preview {
    ContentView()
}
