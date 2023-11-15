class Sudoku {
    var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 6), count: 6)
    var changeable: [(row: Int, column: Int)] = []
    
    func randomize() {
        board[0][0] = Int.random(in: 1 ... 6)
        board[1][3] = Int.random(in: 1 ... 6)
        board[2][1] = Int.random(in: 1 ... 6)
        board[3][4] = Int.random(in: 1 ... 6)
        board[4][2] = Int.random(in: 1 ... 6)
        board[5][5] = Int.random(in: 1 ... 6)
    }
    
    var answer: [[Int]] = []
    
    // 生成符合六宫数独要求的数独板
    func generateBoard() {
        resetBoard()
        randomize()
        answer = solveSudoku(&board)
        hideCells(&board)
    }

    // 重置数独板
        private func resetBoard() {
            for i in 0..<6 {
                for j in 0..<6 {
                    board[i][j] = 0
                }
            }
        }
    
    func solveSudoku(_ board: inout [[Int]]) -> [[Int]] {
        repeat {
            let _ = solve(&board)
        } while !solve(&board)
        return board
    }

    func solve(_ board: inout [[Int]]) -> Bool {
        for i in 0..<6 {
            for j in 0..<6 {
                if board[i][j] == 0 {
                    for num in 1...6 {
                        if isValidMove(board, i, j, num) {
                            board[i][j] = num
                            if solve(&board) {
                                return true
                            }
                            board[i][j] = 0
                        }
                    }
                    return false
                }
            }
        }
        return true
    }

    func isValidMove(_ board: [[Int]], _ row: Int, _ col: Int, _ num: Int) -> Bool {
        // Check row and column
        for i in 0..<6 {
            if board[row][i] == num || board[i][col] == num {
                return false
            }
        }

        // Check 3x2 small grid
        let startRow = (row / 2) * 2
        let startCol = (col / 3) * 3
        for i in startRow..<startRow+2 {
            for j in startCol..<startCol+3 {
                if board[i][j] == num {
                    return false
                }
            }
        }

        return true
    }
    
    func hideCells(_ board: inout [[Int]]) {
        var hiddenCells: [(row: Int, column: Int)] = []

        for _ in 0..<8 { // 可以调整隐藏的格子数量
            var randomRow = Int.random(in: 0..<6)
            var randomCol = Int.random(in: 0..<6)

            // 避免重复隐藏同一个格子
            while hiddenCells.contains(where: { $0.row == randomRow && $0.column == randomCol }) {
                randomRow = Int.random(in: 0..<6)
                randomCol = Int.random(in: 0..<6)
            }

            hiddenCells.append((row: randomRow, column: randomCol))
            board[randomRow][randomCol] = 0
        }

        changeable = hiddenCells
    }
    
    func updateBoard(row: Int, column: Int, with number: Int) {
        let position = (row: row, column: column)
        // Make sure the given row and column is in changeable array
        guard changeable.contains(where: { cell in
            cell == position
        }) else { return }
        
        // 检查给定位置是否在合法范围内
        guard row >= 0, row < 6, column >= 0, column < 6 else {
            print("Invalid row or column.")
            return
        }

        // 检查给定数字是否在合法范围内
        guard number >= 1, number <= 6 else {
            print("Invalid number. Should be between 1 and 6.")
            return
        }

        // 更新指定位置的数值
        board[row][column] = number
    }
}
