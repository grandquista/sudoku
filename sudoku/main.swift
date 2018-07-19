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
        guard board.count == 9 else { exit(1) }
        guard board.filter({ $0.count != 9 }).isEmpty else { exit(1) }
        guard board.joined().compactMap({ $0 }).filter({ $0 > 9 || $0 < 1 }).isEmpty else { exit(1) }
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
    
    func makeValid() -> Board {
        if solutions() == .one {
            return self
        }
        return _makeValid().shuffled().first ?? self
    }
    
    private func _makeValid() -> Array<Board> {
        let next = mutations()
        let output = next.filter { $0.solutions() == .one }
        if output.isEmpty {
            return Array<Board>(next.map { $0._makeValid() }.joined())
        }
        return Array<Board>(output)
    }
    
    private func solutions(x: Int, y: Int) -> Solutions {
        if x >= board.count {
            return solutions(x: 0, y: y+1)
        }
        if y >= board[x].count {
            return .one
        }
        if let i = board[x][y] {
            var hypothesis = board
            hypothesis[x][y] = nil
            if Board(board: hypothesis).posibilities(x: x, y: y).contains(i) {
                return solutions(x: x+1, y: y)
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
    
    private func mutations() -> Array<Board> {
        return Array<Board>(self.board.enumerated().map { (row) in
            row.element.enumerated().map { (cell) -> Array<Board> in
                var hypothesis = self.board
                hypothesis[row.offset][cell.offset] = nil
                let next = Board(board: hypothesis)
                return [next] + next.additions(x: row.offset, y: cell.offset)
            }
            }.joined().joined())
    }
    
    private func additions(x: Int, y: Int) -> Array<Board> {
        return posibilities(x: x, y: y).map {
            var hypothesis = self.board
            hypothesis[x][y] = $0
            return Board(board: hypothesis)
        }
    }
    
    private func posibilities(x: Int, y: Int) -> Set<uint8> {
        let rowBounds = Range(uncheckedBounds: (x - x % 3, x - x % 3 + 3))
        let cellBounds = Range(uncheckedBounds: (y - y % 3, y - y % 3 + 3))
        return Set<uint8>(arrayLiteral: 1, 2, 3, 4, 5, 6, 7, 8, 9)
            .subtracting(board[x].compactMap { $0 })
            .subtracting(column(y: y).compactMap { $0 })
            .subtracting(board.enumerated().map { row in
                row.element.enumerated().compactMap { cell in
                    if rowBounds.contains(row.offset) && cellBounds.contains(cell.offset) {
                        return cell.element
                    }
                    return nil
                }
                }.joined())
    }
    
    private func column(y: Int) -> Array<uint8?> {
        return board.joined().enumerated()
            .filter {
                $0.offset % 8 == y
            }
            .map { $0.element }
    }
    
    private let board: Array<Array<uint8?>>
}

print("Hello, World!")

print("How difficult should this be 0 .. 100?")

guard let rawInput = readLine() else { exit(0) }

let input = rawInput.trimmingCharacters(in: CharacterSet.whitespaces)

guard input.count <= 3 && input.count > 0 else { exit(0) }

guard let difficulty = Int(input) else { exit(0) }

guard difficulty <= 100 && difficulty >= 0 else { exit(0) }

var board = Board(board: Array(repeating: 0, count: 9).map { _ in
    Array(repeating: 0, count: 9).enumerated()
        .map { arc4random_uniform(100) > difficulty ? uint8($0.offset + 1) : nil }
        .shuffled()
    }.shuffled()).makeValid()

board.write()

switch board.solutions() {
case .zero: print("zero")
case .one: print("one")
case .many: print("many")
}
