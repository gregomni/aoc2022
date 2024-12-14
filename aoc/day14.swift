//
//  day14.swift
//  aoc
//
//  Created by Greg Titus on 12/13/24.
//

import Foundation

func dayFourteen(_ contents: String, part1: Bool = false) -> Int {
    let matches = contents.matches(of: /p=(\-?[0-9]+),(\-?[0-9]+) v=(\-?[0-9]+),(\-?[0-9]+)/)

    struct Robot {
        let rx: Int
        let ry: Int
        let dx: Int
        let dy: Int

        func time(_ t: Int) -> (Int,Int) {
            let totalWidth = 101
            let totalHeight = 103

            var x = (rx + dx * t) % totalWidth
            if x < 0 { x += totalWidth }
            var y = (ry + dy * t) % totalHeight
            if y < 0 { y += totalHeight }
            return (x,y)
        }
    }

    var robots: [Robot] = []
    for match in matches {
        robots.append(Robot(rx: Int(match.1)!, ry: Int(match.2)!, dx: Int(match.3)!, dy: Int(match.4)!))
    }

    if part1 {
        let totalWidth = 101
        let totalHeight = 103

        var q = Array(repeating: 0, count: 4)
        for r in robots {
            let (x,y) = r.time(100)
            if x < (totalWidth/2) {
                if y < (totalHeight/2) {
                    q[0] += 1
                } else if y > (totalHeight/2) {
                    q[2] += 1
                }
            } else if x > (totalWidth/2) {
                if y < (totalHeight/2) {
                    q[1] += 1
                } else if y > (totalHeight/2) {
                    q[3] += 1
                }
            }
        }
        return q.reduce(1,*)
    } else {
        let line = String(Array(repeating: ".", count: 101) + ["\n"])
        let all = Array(repeating: line, count: 103).joined()
        let grid = Grid(contents: all)

        var best = 0
        for t in 1 ..< 10000 {
            let g = Grid(copy: grid)
            for r in robots {
                let (x,y) = r.time(t)
                g[x,y] = "#"
            }
            var near = 0
            for i in g.indices where g[i] == "#" {
                let l = i.direction(.left)
                let r = i.direction(.right)
                if g.valid(index: l), g[l] == "#" { near += 1 }
                if g.valid(index: r), g[r] == "#" { near += 1 }
            }
            if near > best {
                print("\(t)")
                g.printGrid()
                print("\n\n\n")
                best = near
            }
        }
        return -1
    }
}
