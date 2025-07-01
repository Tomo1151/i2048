//
//  ContentView.swift
//  i2048
//
//  Created by Tomoyasu on 2025/06/17.
//

import SwiftUI

// 方向のenum
enum Direction {
    case up
    case down
    case left
    case right
}

// マスの構造体
struct Cell {
    var id: Int // 一意のID
    var number: Int
    var x: Int
    var y: Int
    var merged: Bool = false // その移動で結合が起こったかどうか
}

// 結合データ
struct MergeData {
    var FromId: Int
    var ToId: Int
    var number: Int
}

// 移動データ
struct MoveData {
    var id: Int
    var toX: Int
    var toY: Int
    var merged: Bool = false
    var toId: Int?
}

struct ContentView: View {
    //    盤面のサイズ
    let BOARD_SIZE: Int = 4
    
    //    描画サイズ
    let BOARD_PADDING: CGFloat = 10
    let CELL_SIZE: CGFloat = 50
    let CELL_PADDING: CGFloat = 12
    let CELL_TEXT_SIZE: CGFloat = 32
    
    //    生成されるマスが2である確率
    let RANDOM_NUMBER_CHANCE: Double = 0.9
    
    //    移動アニメーションの長さ
    let MOVE_DURATION: Double = 0.2
    
    //    次生成するマスに割り振るID (連番)
    @State private var generatedId: Int = 0
    
    
    //    有効なマスの一覧 (アニメーション用)
    @State private var Cells: [Cell] = [
        //    Cell(id: 0, number: 2, x: 0, y: 0),
        //    Cell(id: 1, number: 4, x: 1, y: 0),
        //    Cell(id: 2, number: 4, x: 2, y: 0),
        //    Cell(id: 3, number: 16, x: 3, y: 0),
        //    Cell(id: 4, number: 32, x: 0, y: 1),
        //    Cell(id: 5, number: 32, x: 1, y: 1),
        //    Cell(id: 6, number: 128, x: 2, y: 1),
        //    Cell(id: 7, number: 256, x: 3, y: 1),
        //    Cell(id: 8, number: 512, x: 0, y: 2),
        //    Cell(id: 9, number: 32, x: 1, y: 2),
        //    Cell(id: 10, number: 2048, x: 2, y: 2),
        //    Cell(id: 11, number: 2, x: 0, y: 3),
        //    Cell(id: 12, number: 2, x: 1, y: 3),
        //    Cell(id: 13, number: 2, x: 2, y: 3),
        //    Cell(id: 14, number: 2, x: 3, y: 3),
    ]
    
    //    メインビュー
    var body: some View {
        ZStack {
            //            背景色
            Color("body_bg").edgesIgnoringSafeArea(.all)
            
            //            背景の枠/マスの描画
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
            
            //            数字のあるマスの描画
            ForEach(Cells, id: \.id) { cell in
                //                盤の真ん中を計算
                let center = Double(BOARD_SIZE - 1) / 2
                
                //                マスの(x, y)をもとに描画位置を計算
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
            //            盤面初回描画時にランダムで2マス生成
            if Cells.isEmpty {
                generateRandomCell(count: 2)
            }
        }
    }
    
    //    マスのインデックス内の乱数を生成
    func generateRandomCell(count: Int) {
        for _ in 0..<count {
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
    
    //    指定したライン上のマスが指定した方向に動いた時に結合が起こるマスを計算
    func calcMerge(direction: Direction, line: Int) -> [MergeData] {
        //        動かす列(行)をソートして取得
        let line: [Cell] = getSortedLine(direction: direction, line: line)
        
        //        結合されるマスの情報
        var merged: [MergeData] = []
        if line.count < 2 { return merged }
        
        //        マスを結合
        for i in 0..<(line.count-1) {
            //            既に結合済みなら考慮しない
            if merged.contains(where: {$0.FromId == line[i].id}) { continue }
            
            //            条件を満たしていたら結合し，結合済みであることをマーク
            if line[i].number == line[i+1].number {
                if let index = findCellIndexById(id: line[i+1].id) {
                    Cells[index].merged = true
                }
                
                //                結合されるマスの一覧に追加
                merged.append(MergeData(FromId: line[i+1].id, ToId: line[i].id, number: line[i].number))
            }
        }
        
        return merged
    }
    
    
    //    指定したライン上のマスを指定した方向に動かした時にマスを端っこから詰める
    func alignCells(direction: Direction, lineNum: Int) -> [MoveData] {
        //        移動予定マス一覧
        var moves: [MoveData] = []
        
        //        揃える列または行をソートして取得（merged = falseのもののみ）
        let sortedLine = getSortedLine(direction: direction, line: lineNum).filter { !$0.merged }
        
        //        向きが反転するかどうか
        let invert = !(direction == .up || direction == .left)
        
        for (count, cell) in sortedLine.enumerated() {
            var toX: Int
            var toY: Int
            
            if direction == .up || direction == .down {
                //                縦方向の時はXを書き換え
                toX = cell.x
                toY = invert ? BOARD_SIZE - count - 1 : count
            } else {
                //                横方向の時はYを書き換え
                toX = invert ? BOARD_SIZE - count - 1 : count
                toY = cell.y
            }
            
            //            X座標またはY座標が変化した(= 移動が発生した)時のみ移動予定マス一覧に追加
            if toX != cell.x || toY != cell.y {
                moves.append(MoveData(id: cell.id, toX: toX, toY: toY))
            }
        }
        return moves
    }
    
    //    指定したライン上のマスを指定した向きでソートして取得
    func getSortedLine(direction: Direction, line: Int) -> [Cell] {
        //        方向別フィルタリング条件のクロージャ
        let filterClosureMap: [Direction: (Cell) -> Bool] = [
            .up: { (cell: Cell) -> Bool in cell.x == line },
            .down: { (cell: Cell) -> Bool in cell.x == line },
            .right: { (cell: Cell) -> Bool in cell.y == line },
            .left: { (cell: Cell) -> Bool in cell.y == line },
        ]
        
        //        方向別ソート条件のクロージャ
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
    
    //    実際に移動計画を立てて移動を行う
    func move(direction: Direction) {
        //        移動予定のマス一覧
        var moves: [MoveData] = []
        
        for i in 0..<BOARD_SIZE {
            //            結合が起こるマスを計算
            let merged = calcMerge(direction: direction, line: i)
            
            //            マスを揃えた時の移動を計算
            let aligned = alignCells(direction: direction, lineNum: i)
            
            //            結合されるマスを移動情報に変換（移動後の座標を考慮）し移動予定の一覧に追加
            for j in 0..<merged.count {
                if let move = getMoveFromMergeData(merge: merged[j], alignedMoves: aligned) {
                    moves.append(move)
                }
            }
            
            //            揃えた時の移動予定を一覧に追加
            for j in 0..<aligned.count {
                moves.append(aligned[j])
            }
        }
        
        //        移動予定マスが0だった時は何もしない
        if moves.count == 0 { return }
        
        print("移動予定：")
        print(moves)
        
        // すべてのアニメーションが完了したかを追跡
        var completedAnimations = 0
        let totalAnimations = moves.count
        
        // すべてのセルを移動
        for move in moves {
            //            移動予定を元にアニメーション付きで移動
            moveCellTo(id: move.id, x: move.toX, y: move.toY, onFinish: {
                //                アニメーション終了後に完了カウントを1追加
                completedAnimations += 1
                
                // すべてのアニメーションが完了した時
                if completedAnimations == totalAnimations {
                    for move in moves {
                        //                        結合が発生した移動についての処理
                        if move.merged {
                            // 結合が起こって無くなったマスを一覧から削除
                            deleteCellById(id: move.id)
                            // 結合された側のマスの数字を2倍にする
                            if let toId = move.toId, let index = self.findCellIndexById(id: toId) {
                                Cells[index].number *= 2
                            }
                        }
                    }
                    
                    // 新しいセルを生成
                    generateRandomCell(count: 1)
                }
            })
        }
    }
    
    //    結合データを元に移動データを生成
    func getMoveFromMergeData(merge: MergeData, alignedMoves: [MoveData]) -> MoveData? {
        if let cellFrom = findCellById(id: merge.FromId),
           let cellTo = findCellById(id: merge.ToId)
        {
            // マージ対象のセル（ToId）が移動する場合、その移動後の座標を取得
            var targetX = cellTo.x
            var targetY = cellTo.y
            
            // alignedMovesから目標セルの移動先を探す
            if let alignedMove = alignedMoves.first(where: { $0.id == merge.ToId }) {
                targetX = alignedMove.toX
                targetY = alignedMove.toY
            }
            
            return MoveData(id: cellFrom.id, toX: targetX, toY: targetY, merged: true, toId: cellTo.id)
        }
        return nil
    }
    
    //    アニメーション付きでマスを移動する関数
    func moveCellTo(id: Int, x: Int, y: Int, onFinish: (() -> Void)? = nil) {
        if let index = Cells.firstIndex(where: { $0.id == id }) {
            withAnimation(.easeInOut(duration: MOVE_DURATION)) {
                //                指定した秒数かけて描画位置を移動
                Cells[index].x = x
                Cells[index].y = y
            } completion: {
                if let handler = onFinish {
                    //                    onFinishハンドラがあればアニメーション完了後に実行
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
        
        
        move(direction: swipeDirection)
    }
}

#Preview {
    ContentView()
}
