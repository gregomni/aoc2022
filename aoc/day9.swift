//
//  day9.swift
//  aoc
//
//  Created by Greg Titus on 12/8/24.
//

import Foundation

func dayNine(_ contents: String, part1: Bool = false) -> Int {
    struct File {
        var id: Int
        var length: Int
        var free: Bool { id == -1 }
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
                fileID -= 1
            } else if files[dst].length < f.length {
                files[src].length -= files[dst].length
                files[dst].id = fileID
            } else if files[dst].length == f.length {
                files[src].id = -1
                files[dst].id = fileID
                fileID -= 1
            } else {
                files[src].id = -1
                files[dst].length -= f.length
                files.insert(f, at: dst)
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
                files[index].id = -1

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
