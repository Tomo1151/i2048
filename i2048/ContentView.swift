//
//  ContentView.swift
//  i2048
//
//  Created by Tomoyasu on 2025/06/17.
//

import SwiftUI

enum Direction {
    case up
    case down
    case left
    case right
}

struct Cell {
    var id: Int
    var number: Int
    var x: Int
    var y: Int
}

struct MergeData {
    var FromId: Int
    var ToId: Int
}

struct ContentView: View {
//    盤面のサイズ
    let BOARD_SIZE: Int = 4
    let BOARD_PADDING: CGFloat = 10
    let CELL_SIZE: CGFloat = 50
    let CELL_PADDING: CGFloat = 12
    let CELL_TEXT_SIZE: CGFloat = 32
    let RANDOM_NUMBER_CHANCE: Double = 0.9
    
//    次に割り振るID (連番)
    @State private var generatedId: Int = 0
    
////    盤面チェック用配列
//    @State private var board: [[Int?]] = [
//        [nil, nil, nil, nil],
//        [nil, nil, nil, nil],
//        [nil, nil, nil, nil],
//        [nil, nil, nil, nil],
//    ]
    
//    既に数字のあるマスの一覧 (アニメーション用)
    @State private var Cells: [Cell] = [
//        Cell(id: 0, number: 2, x: 0, y: 0),
//        Cell(id: 1, number: 4, x: 1, y: 0),
//        Cell(id: 2, number: 4, x: 2, y: 0),
//        Cell(id: 3, number: 16, x: 3, y: 0),
//        Cell(id: 4, number: 32, x: 0, y: 1),
//        Cell(id: 5, number: 32, x: 1, y: 1),
//        Cell(id: 6, number: 128, x: 2, y: 1),
//        Cell(id: 7, number: 256, x: 3, y: 1),
//        Cell(id: 8, number: 512, x: 0, y: 2),
//        Cell(id: 9, number: 32, x: 1, y: 2),
//        Cell(id: 10, number: 2048, x: 2, y: 2),
//        Cell(id: 11, number: 2, x: 0, y: 3),
//        Cell(id: 12, number: 2, x: 1, y: 3),
//        Cell(id: 13, number: 2, x: 2, y: 3),
//        Cell(id: 14, number: 2, x: 3, y: 3),
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
        .onAppear {
            if Cells.isEmpty {
                generateRandomCell(count: 2)
            }
        }
    }
    
//    マスのインデックス内の乱数を生成
    func generateRandomCell(count: Int) {
        for i in 0..<count {
            while (true) {
                let x = Int.random(in: 0..<BOARD_SIZE)
                let y = Int.random(in: 0..<BOARD_SIZE)
                
                if !Cells.contains(where: { cell in cell.x == x && cell.y == y }) {
                    let cell = Cell(id: generatedId, number: Double.random(in: 0...1) < RANDOM_NUMBER_CHANCE ? 2 : 4, x: x, y: y)
                    Cells.append(cell)
                    generatedId += 1
                    break
                }
            }
        }
    }
    
//    数字のマスを追加
//    func addCell(value: Int, x: Int, y: Int) -> Void {
//        board[y][x] = value
//        Cells.append(Cell(id: generatedId, number: value, x: x, y: y))
//        generatedId += 1
//    }
    
//    指定した方向へ指定したラインを動かす
    func move(direction: Direction, line: Int) -> [MergeData] {
//        動かす列(行)をソートして取得
        let line: [Cell] = getSortedLine(direction: direction, line: line)
        
//        結合されるマスの情報
        var merged: [MergeData] = []
        if line.count < 2 { return merged }
        
//        マスを結合
        for i in 0..<(line.count-1) {
//            既に結合済みならスキップ
            if merged.contains(where: {$0.FromId == line[i].id}) { continue }
            
//            条件を満たしていたら結合
            if line[i].number == line[i+1].number {
                merged.append(MergeData(FromId: line[i+1].id, ToId: line[i].id))
            }
        }
        
        return merged
    }
    
    
    func alignCells(direction: Direction, line: Int) {
        // 揃える列または行をソートして取得
        let line = getSortedLine(direction: direction, line: line)
        
        // 並べる方向に応じてインデックスの並び順を決める
        let range: [Int] = (direction == .up || direction == .left)
            ? Array(0..<BOARD_SIZE)
            : Array((0..<BOARD_SIZE).reversed())

        // line.count 分だけ range を使う（index out of range を防ぐ）
        for (j, cell) in line.enumerated() {
            if j >= range.count { break } // 念のため安全に

            if let index = findCellIndexById(id: cell.id) {
                if direction == .up || direction == .down {
                    moveCellTo(id: cell.id, x: cell.x, y: range[j])
                    Cells[index].y = range[j]
                } else {
                    moveCellTo(id: cell.id, x: range[j], y: cell.y)
                    Cells[index].x = range[j]
                }
            }
        }
    }
    
    

    func getSortedLine(direction: Direction, line: Int) -> [Cell] {
//        同一列(行)をフィルタリングするためのクロージャ
        let filterClosureMap: [Direction: (Cell) -> Bool] = [
            .up: { (cell: Cell) -> Bool in cell.x == line },
            .down: { (cell: Cell) -> Bool in cell.x == line },
            .right: { (cell: Cell) -> Bool in cell.y == line },
            .left: { (cell: Cell) -> Bool in cell.y == line },
        ]
        
//        ソートするためのクロージャ
        let sortClosureMap: [Direction: (Cell, Cell) -> Bool] = [
            .up: { (cell0: Cell, cell1: Cell) -> Bool in cell0.y < cell1.y },
            .down: { (cell0: Cell, cell1: Cell) -> Bool in cell0.y > cell1.y },
            .left: { (cell0: Cell, cell1: Cell) -> Bool in cell0.x < cell1.x },
            .right: { (cell0: Cell, cell1: Cell) -> Bool in cell0.x > cell1.x },
        ]
        
//        選択した列(行)をソートして取得
        return Cells
            .filter(filterClosureMap[direction]!)
            .sorted(by: sortClosureMap[direction]!)
    }
    
    func mergeCells(direction: Direction) {
        for i in 0..<BOARD_SIZE {
            let merged = move(direction: direction, line: i)
            
            if merged.count == 0 {
                alignCells(direction: direction, line: i)
                continue
            }
        
            for i in 0..<merged.count {
                let cellFrom = findCellById(id: merged[i].FromId)!
                let cellTo = findCellById(id: merged[i].ToId)!

                moveCellTo(id: cellFrom.id, x: cellTo.x, y: cellTo.y, onFinish: {
//                    マスの数字を結合し，マスの配列から削除
                    if let cellIndex = findCellIndexById(id: cellTo.id) {
                        Cells[cellIndex].number *= 2
                        deleteCellById(id: cellFrom.id)
                        alignCells(direction: direction, line: i)
                    }
                })
            }
        }
        generateRandomCell(count: 1)
    }

//    アニメーション付きでマスを移動する関数
    func moveCellTo(id: Int, x: Int, y: Int, onFinish: (() -> Void)? = nil) {
        if let index = Cells.firstIndex(where: { $0.id == id }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                Cells[index].x = x
                Cells[index].y = y
            } completion: {
                if let handler = onFinish {
                    handler()
                }
            }
        }
    }
    
//    IDからマスを取得する関数
    func findCellById(id: Int) -> Cell? {
        return Cells.first { $0.id == id }
    }
    
//    IDからマスのインデックスを取得する関数
    func findCellIndexById(id: Int) -> Int? {
        return Cells.firstIndex(where: { $0.id == id })
    }
    
//    IDでマスを削除する関数
    func deleteCellById(id: Int) {
        if let index = Cells.firstIndex(where: { $0.id == id }) {
            Cells.remove(at: index)
        }
    }
    
//    画面スワイプのハンドラ
    func handleSwipe(translationX: CGFloat, translationY: CGFloat) -> Void {
        var swipeDirection: Direction
        
        if abs(translationX) > abs(translationY) {
//            水平方向
            if translationX > 0 {
//                右
                print("右にスワイプされました")
                swipeDirection = .right
            } else {
//                左
                print("左にスワイプされました")
                swipeDirection = .left
            }
        } else {
            if translationY > 0 {
//                            下
                print("下にスワイプされました")
                swipeDirection = .down
            } else {
//                            上
                print("上にスワイプされました")
                swipeDirection = .up
            }
        }
        

//            print("\(i+1)行目：\(merged)")
            mergeCells(direction: swipeDirection)
    }
}

#Preview {
    ContentView()
}
