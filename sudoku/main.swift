//
//  main.swift
//  sudoku
//
//  Created by Adam Grandquist on 7/18/18.
//  Copyright © 2018 Adam Grandquist. All rights reserved.
//

import Foundation

enum Solutions {
    case zero
    case one
    case many
}

class Board {
    init(board: Array<Array<uint8?>>) {
        self.board = board
    }
    
    func write() {
        print("-------------------")
        for row in board {
            var rowRepr = "|"
            for i in row {
                if let i: uint8 = i {
                    rowRepr += String(i, radix: 10, uppercase: false) + "|"
                } else {
                    rowRepr += " |"
                }
            }
            print(rowRepr)
            print("-------------------")
        }
    }
    
    func solutions() -> Solutions {
        return solutions(x: 0, y: 0)
    }
    
    func solutions(x: Int, y: Int) -> Solutions {
        if x >= board.count {
            return solutions(x:0, y:y+1)
        }
        if y >= board[0].count {
            return .one
        }
        if board[x][y] == nil {
            var solutions = Solutions.zero
            var hypothesis = board
            for i in posibilities(x: x, y: y) {
                hypothesis[x][y] = i
                switch (Board(board: hypothesis).solutions(x: x, y: y), solutions) {
                case (.zero, .one), (.one, .zero): solutions = .one
                case (.zero, .zero): break
                default: return .many
                }
            }
            return solutions
        }
        return solutions(x:x+1, y:y)
    }
    
    private func posibilities(x: Int, y: Int) -> Array<uint8> {
        var ideas = Set<uint8>(arrayLiteral: 1, 2, 3, 4, 5, 6, 7, 8, 9)
        for i in board[x] {
            if let i: uint8 = i {
                ideas.remove(i)
            }
        }
        for i in column(y:y) {
            if let i: uint8 = i {
                ideas.remove(i)
            }
        }
        for (i, row) in board.enumerated() {
            if Range(uncheckedBounds: (0, 1)).contains(i) {
                for (j, cell) in row.enumerated() {
                    if Range(uncheckedBounds: (0, 1)).contains(j) {
                        if let cell: uint8 = cell {
                            ideas.remove(cell)
                        }
                    }
                }
            }
        }
        return Array<uint8>(ideas)
    }
    
    private func column(y: Int) -> Array<uint8?> {
        var output = Array<uint8?>()
        for (n, i) in board.lazy.joined().enumerated() {
            if n % 8 == y {
                output.append(i)
            }
        }
        return output
    }
    
    private let board: Array<Array<uint8?>>
}

print("Hello, World!")

var board = Board(board: Array(repeating: Array<uint8?>(repeating: nil, count: 9), count: 9))

board.write()

switch board.solutions() {
case .zero: print("zero")
case .one: print("one")
case .many: print("many")
}
