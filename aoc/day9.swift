//
//  day9.swift
//  aoc
//
//  Created by Greg Titus on 12/8/24.
//

import Foundation
import Collections

func dayNine_old(_ contents: String, part1: Bool = false) -> Int {
    struct File {
        var id: Int
        var length: Int
        var free: Bool { get { id == -1 } set { id = -1 } }
        func checksum(startingAt block: Int) -> Int {
            if free { return 0 }
            return (block ..< block + length).reduce(0, { $0 + $1 * id })
        }
    }

    var files: [File] = []
    let charArray = Array(contents)
    for i in charArray.indices {
        guard let length = Int(String(charArray[i])) else { continue }
        let free = (i % 2 == 1)
        files.append(File(id: free ? -1 : i / 2, length: length))
    }

    if part1 {
        var fileID = files.last!.id
        while fileID > 0 {
            let src = files.lastIndex(where: { $0.id == fileID })!
            let dst = files.firstIndex(where: { $0.free })!
            let f = files[src]

            if dst > src {
                break
            } else if files[dst].length < f.length {
                files[src].length -= files[dst].length
                files[dst].id = fileID
            } else {
                files[src].free = true
                if files[dst].length == f.length {
                    files[dst].id = fileID
                } else {
                    files[dst].length -= f.length
                    files.insert(f, at: dst)
                }
                fileID -= 1
            }
        }
    } else {
        var fileID = files.last!.id
        while fileID > 0 {
            let index = files.firstIndex(where: { $0.id == fileID })!
            let f = files[index]
            for i in 0 ..< index {
                guard files[i].free, files[i].length >= f.length else { continue }
                files[index].free = true

                if files[i].length == f.length {
                    files[i].id = f.id
                } else {
                    files[i].length -= f.length
                    files.insert(f, at: i)
                }
                break
            }
            fileID -= 1
        }
    }

    var block = 0
    var result = 0
    for f in files {
        result += f.checksum(startingAt: block)
        block += f.length
    }
    return result
}

// HEAPS!
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
