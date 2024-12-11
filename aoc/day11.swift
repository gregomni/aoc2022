//
//  day11.swift
//  aoc
//
//  Created by Greg Titus on 12/10/24.
//

import Foundation

func dayEleven(_ contents: String) -> Int {
    let startingList = contents.dropLast().components(separatedBy: " ").map { Int($0)! }
    struct Possibility: Hashable {
        let stone: Int
        let blinks: Int
    }
    var memo: [Possibility : Int] = [:]

    func doIt(stone: Int, blinks: Int) -> Int {
        if blinks == 0 {
            return 1
        }
        if let result = memo[Possibility(stone: stone, blinks: blinks)] {
            return result
        }

        let result: Int
        if stone == 0 {
            result = doIt(stone: 1, blinks: blinks-1)
        } else {
            let string = stone.description
            if string.count % 2 == 0 {
                let i = string.index(string.startIndex, offsetBy: string.count / 2)
                let a = Int(string.prefix(upTo: i))!
                let b = Int(string.suffix(from: i))!
                result = doIt(stone: a, blinks: blinks-1) + doIt(stone: b, blinks: blinks-1)
            } else {
                result = doIt(stone: stone * 2024, blinks: blinks-1)
            }
        }
        memo[Possibility(stone: stone, blinks: blinks)] = result
        return result
    }

    var result = 0
    for number in startingList {
        result += doIt(stone: number, blinks: 75)
    }
    print("memo size= \(memo.count)")
    return result
}
