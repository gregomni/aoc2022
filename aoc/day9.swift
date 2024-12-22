//
//  day9.swift
//  aoc
//
//  Created by Greg Titus on 12/8/24.
//

import Foundation
import Collections

func dayNine(_ contents: String) -> Int {
    struct File {
        var id: Int
        var length: Int
        var block: Int
        func checksum() -> Int {
            return (block ..< block + length).reduce(0, { $0 + $1 * id })
        }
    }

    var files: [File] = []
    // a heap sorted on earliest-on-disk for each possible free size (0 is here but unused)
    var freeHeaps = Array(repeating: Heap<Int>(), count: 10)
    let charArray = Array(contents)
    var block = 0
    for i in charArray.indices {
        guard let length = charArray[i].wholeNumberValue else { continue }
        if (i % 2 == 1) {
            freeHeaps[length].insert(block)
        } else {
            files.append(File(id: i / 2, length: length, block: block))
        }
        block += length
    }

    var result = 0
    for var file in files.reversed() {
        var moveTo = file.block
        var heap: Int? = nil
        // find the earliest free block big enough to fit this file
        for possibleHeap in file.length ... 9 {
            if let freeBlock = freeHeaps[possibleHeap].min, freeBlock < moveTo {
                moveTo = freeBlock
                heap = possibleHeap
            }
        }
        if let heap {
            let moveTo = freeHeaps[heap].popMin()!
            file.block = moveTo
            if heap > file.length {
                freeHeaps[heap - file.length].insert(moveTo + file.length)
            }
        }
        result += file.checksum()
    }
    return result
}
