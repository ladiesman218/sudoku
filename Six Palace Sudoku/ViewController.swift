//
//  ViewController.swift
//  Six Palace Sudoku
//
//  Created by Lei Gao on 2023/11/15.
//  TODO:
//  1. Main thread blocking
//  2. UI adjustment
//  3. Changing difficulty level
//  4. Optimize board updating
//  5. Other optimizations
//  6. Localization
//  7. Hint button to yeild a random unsolved cell
//  8. Check if user input an valid answer base on current values in board

import UIKit

class ViewController: UIViewController {
    
    let gridSize: CGFloat = screenWidth / 6 - 5
    let gap: CGFloat = 5
    
    private let newGameButton: UIButton = {
        let button = UIButton()
        button.setTitle("  New Game  ", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let boardContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let buttonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    let sudoku = Sudoku()
    
    var selectedCell: (Int, Int)? = nil {
        didSet {
            restoreBGColor()
            if let selectedCell = selectedCell {
                highlightRowAndColumn(row: selectedCell.0, col: selectedCell.1)
            }
            for subview in buttonContainer.subviews {
                if let button = subview as? UIButton {
                    button.isEnabled = selectedCell != nil
                }
            }
        }
    }
    
    func displayButtons() {
        for i in 1 ... 6 {
            let button = UIButton()
            button.setTitle(String(i), for: .normal)
            button.isEnabled = false
            
            button.setTitleColor(.systemOrange, for: .normal)
            button.setTitleColor(.gray, for: .disabled)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: gridSize / 1.5)
            button.tag = i
            
            button.frame = CGRect(x: CGFloat((i - 1) % 3) * ((screenWidth - 40) / 3),
                                  y: CGFloat((i - 1) / 3) * (gridSize + gap),
                                  width: (screenWidth - 40) / 3 - gap,
                                  height: gridSize)
            button.addTarget(self, action: #selector(updateBoard), for: .touchUpInside)
            buttonContainer.addSubview(button)
        }
    }
    
    // Triggered when an answer button is tapped
    @objc func updateBoard(sender: UIButton) {
        let number = sender.tag
        guard let selectedCell = selectedCell else { return }
        
        // Get selected cell's position
        let position = (row: selectedCell.0, column: selectedCell.1)
        // Get selected label
        guard let label = view.viewWithTag(selectedCell.0 * 6 + selectedCell.1 + 1) as? UILabel else {
            fatalError("can't find label")
        }
        
        // Update datasource
        sudoku.updateBoard(row: position.row, column: position.column, with: number)
        // Update view
        label.text = String(number)
        label.textColor = (number == sudoku.answer[position.row][position.column]) ? .black : .red
        
        // Check if user has the correct answer
        if sudoku.board == sudoku.answer {
            let alertVC = UIAlertController(title: "Congratulations!", message: "You made it!!", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alertVC.addAction(ok)
            self.present(alertVC, animated: true)
        }
        
        self.selectedCell = nil
    }
    
    func displaySudokuBoard() {
        for label in boardContainer.subviews {
            label.removeFromSuperview()
        }
        selectedCell = nil
        
        for i in 0..<6 {
            for j in 0..<6 {
                let label = UILabel(frame: CGRect(x: CGFloat(j) * (gridSize + gap),
                                                  y: CGFloat(i) * (gridSize + gap),
                                                  width: gridSize,
                                                  height: gridSize))
                label.textAlignment = .center
                label.backgroundColor = defaultGridColor
                label.text = sudoku.board[i][j] == 0 ? "" : "\(sudoku.board[i][j])"
                
                label.isUserInteractionEnabled = sudoku.board[i][j] == 0
                if label.isEnabled {
                    label.textColor = .systemBlue
                    label.font = UIFont.boldSystemFont(ofSize: label.frame.height / 2.5)
                }
                label.tag = i * 6 + j + 1
                
                // Add divider for column
                if j == 2 {
                    let borderLayer = CALayer()
                    
                    borderLayer.frame = CGRect(x: label.frame.width, y: 0, width: gap, height: label.frame.height * 1.1)
                    borderLayer.backgroundColor = dividerColor.cgColor
                    
                    // 将CALayer添加到UILabel的layer中
                    label.layer.addSublayer(borderLayer)
                }
                // Add divider for row
                if i == 1 || i == 3 {
                    // 创建一个CALayer作为边框
                    let borderLayer = CALayer()
                    borderLayer.frame = CGRect(x: 0, y: label.frame.height, width: label.frame.width * 1.1, height: gap)
                    borderLayer.backgroundColor = dividerColor.cgColor
                    
                    // 将CALayer添加到UILabel的layer中
                    label.layer.addSublayer(borderLayer)
                }
                
                label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:))))
                boardContainer.addSubview(label)
            }
        }
    }
    
    @objc func cellTapped(_ gesture: UITapGestureRecognizer) {
        
        if let tappedLabel = gesture.view as? UILabel {
            let row = (tappedLabel.tag - 1) / 6
            let col = (tappedLabel.tag - 1) % 6
            let cell = (row, col)
            guard sudoku.changeable.contains(where: { position in
                position == cell
            }) else { return }
            
            if let selectedCell = selectedCell, selectedCell == cell {
                self.selectedCell = nil
                return
            }
            selectedCell = cell
        }
    }
    
    // Restore default background color for all cells
    func restoreBGColor() {
        for i in 0..<6 {
            for j in 0..<6 {
                if let label = view.viewWithTag(i * 6 + j + 1) as? UILabel {
                    label.backgroundColor = defaultGridColor
                }
            }
        }
    }
    
    func highlightRowAndColumn(row: Int, col: Int) {
        
        // Highlight the selected row with different background color
        for i in 0 ..< 6 {
            if let label = view.viewWithTag(i * 6 + col + 1) as? UILabel {
                label.backgroundColor = selectedGridColor
            }
        }
        
        // Highlight the selected column with different background color
        for j in 0 ..< 6 {
            if let label = view.viewWithTag(row * 6 + j + 1) as? UILabel {
                label.backgroundColor = selectedGridColor
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(newGameButton)
        newGameButton.addTarget(self, action: #selector(newGame), for: .touchUpInside)
        view.addSubview(boardContainer)
        view.addSubview(buttonContainer)
        
        sudoku.generateBoard()
        displaySudokuBoard()
        displayButtons()
        
        NSLayoutConstraint.activate([
            newGameButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            newGameButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            boardContainer.topAnchor.constraint(equalTo: newGameButton.bottomAnchor, constant: 20),
            boardContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            boardContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            boardContainer.heightAnchor.constraint(equalTo: boardContainer.widthAnchor),
            
            buttonContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonContainer.topAnchor.constraint(equalTo: boardContainer.bottomAnchor, constant: 20),
            buttonContainer.heightAnchor.constraint(equalToConstant: gridSize * 2 + 5)
        ])
    }
    
    @objc func newGame() {
        sudoku.generateBoard()
        displaySudokuBoard()
    }
}

