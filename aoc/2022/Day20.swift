//
//  Day20.swift
//  aoc
//
//  Created by Greg Titus on 12/20/22.
//

import Foundation

func twenty2022_part1(_ contents: String) -> Int {
    let numbers = contents.components(separatedBy: "\n").filter({ !$0.isEmpty }).map({ Int($0)! })
    let count = numbers.count
    var mixed = Array(zip(numbers, 0 ..< count))

    for i in numbers.indices {
        let index = mixed.firstIndex(where: { $0.1 == i })!
        var newPosition = (index + numbers[i]) % (count-1)
        guard index != newPosition else { continue }
        if newPosition == 0, numbers[i] < 0 {
            newPosition = count - 1
        } else if newPosition < 0 {
            newPosition += count - 1
        }
        mixed.remove(at: index)
        mixed.insert((numbers[i], i), at: newPosition)
    }

    let index = mixed.firstIndex(where: { $0.0 == 0 })!
    let first = mixed[(index+1000) % count]
    let second = mixed[(index+2000) % count]
    let third = mixed[(index+3000) % count]
    return first.0 + second.0 + third.0
}

func twenty2022(_ contents: String) -> Int {
    let numbers = contents.components(separatedBy: "\n").filter({ !$0.isEmpty }).map({ Int($0)! * 811589153 })
    let count = numbers.count
    var mixed = Array(zip(numbers, 0 ..< count))

    for _ in 0 ..< 10 {
        for i in numbers.indices {
            let index = mixed.firstIndex(where: { $0.1 == i })!
            var newPosition = (index + numbers[i]) % (count-1)
            guard index != newPosition else { continue }
            if newPosition == 0, numbers[i] < 0 {
                newPosition = count - 1
            } else if newPosition < 0 {
                newPosition += count - 1
            }
            mixed.remove(at: index)
            mixed.insert((numbers[i], i), at: newPosition)
        }
    }
    let index = mixed.firstIndex(where: { $0.0 == 0 })!
    let first = mixed[(index+1000) % count]
    let second = mixed[(index+2000) % count]
    let third = mixed[(index+3000) % count]
    return first.0 + second.0 + third.0
}
