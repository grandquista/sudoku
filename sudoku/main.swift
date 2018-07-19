//
//  main.swift
//  sudoku
//
//  Created by Adam Grandquist on 7/18/18.
//  Copyright © 2018 Adam Grandquist. All rights reserved.
//

import Foundation

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

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
        if let i = board[x][y] {
            var hypothesis = board
            hypothesis[x][y] = nil
            if Board(board: hypothesis).posibilities(x: x, y: y).contains(i) {
                return solutions(x:x+1, y:y)
            }
            return .zero
        }
        var result = Solutions.zero
        var hypothesis = board
        for i in posibilities(x: x, y: y) {
            hypothesis[x][y] = i
            switch (Board(board: hypothesis).solutions(x: x, y: y), result) {
            case (.zero, .one), (.one, .zero): result = .one
            case (.zero, .zero): break
            default: return .many
            }
        }
        return result
    }
    
    private func posibilities(x: Int, y: Int) -> Set<uint8> {
        let rowBounds = Range(uncheckedBounds: (x - x % 3, x - x % 3 + 3))
        let cellBounds = Range(uncheckedBounds: (y - y % 3, y - y % 3 + 3))
        return Set<uint8>(arrayLiteral: 1, 2, 3, 4, 5, 6, 7, 8, 9)
            .subtracting(board[x].lazy.compactMap { $0 })
            .subtracting(column(y: y).lazy.compactMap { $0 })
            .subtracting(board.lazy.enumerated().map { row in
                row.element.lazy.enumerated().compactMap { cell in
                    if rowBounds.contains(row.offset) && cellBounds.contains(cell.offset) {
                        return cell.element
                    }
                    return nil
                }
            }.joined())
    }
    
    private func column(y: Int) -> Array<uint8?> {
        return board.lazy.joined().enumerated()
            .filter {
                $0.offset % 8 == y
            }
            .map { $0.element }
    }
    
    private let board: Array<Array<uint8?>>
}

print("Hello, World!")

print("How difficult should this be 0 .. 100?")

let difficulty = readLine()

guard difficulty != nil else { exit(0) }

var board = Board(board: Array(repeating: 0, count: 9).map { _ in
    Array(repeating: 0, count: 9).enumerated()
        .map { arc4random_uniform(100) > 50 ? uint8($0.offset + 1) : nil }
        .shuffled()
}.shuffled())

board.write()

switch board.solutions() {
case .zero: print("zero")
case .one: print("one")
case .many: print("many")
}
