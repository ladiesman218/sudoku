class Sudoku {
	var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 6), count: 6)
	var changeable: [(row: Int, column: Int)] = []
	
	func randomize() {
		#warning("Could generate an un-solvable board")
		board[0][0] = Int.random(in: 1 ... 6)
		board[1][3] = Int.random(in: 1 ... 6)
		board[2][1] = Int.random(in: 1 ... 6)
		board[3][4] = Int.random(in: 1 ... 6)
		board[4][2] = Int.random(in: 1 ... 6)
		board[5][5] = Int.random(in: 1 ... 6)
	}
	
	var answer: [[Int]] = []
	
	func generateBoard() {
		resetBoard()
		randomize()
		answer = solveSudoku(&board)
		hideCells(&board)
	}
	
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
	
	// Hide cells at random location on board by setting their value to 0
	func hideCells(_ board: inout [[Int]]) {
		// A array of locations to hold hidden cells
		var hiddenCells: [(row: Int, column: Int)] = []
		
		for _ in 0..<8 { // adjust the range
			var randomRow = Int.random(in: 0..<6)
			var randomCol = Int.random(in: 0..<6)
			
			// Avoid hiding the same number more than 1 time
			while hiddenCells.contains(where: { $0.row == randomRow && $0.column == randomCol }) {
				randomRow = Int.random(in: 0..<6)
				randomCol = Int.random(in: 0..<6)
			}
			
			board[randomRow][randomCol] = 0
			hiddenCells.append((row: randomRow, column: randomCol))
		}
		
		changeable = hiddenCells
	}
	
	func updateBoard(row: Int, column: Int, with number: Int) {
		let position = (row: row, column: column)
		// Make sure the given row and column is in changeable array
		guard changeable.contains(where: { cell in
			cell == position
		}) else { return }
		
		// Check if given location is legit
		guard row >= 0, row < 6, column >= 0, column < 6 else {
			print("Invalid row or column.")
			return
		}
		
		// Check if given number is legit
		guard number >= 1, number <= 6 else {
			print("Invalid number. Should be between 1 and 6.")
			return
		}
		
		// UPdate number at the given location
		board[row][column] = number
	}
}
