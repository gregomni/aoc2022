//
//  WrappingMap.swift
//  aoc
//
//  Created by Greg Titus on 12/22/22.
//

import Foundation
import RegexBuilder

enum WalkSpot: Character {
    case empty = "."
    case wall = "#"
    case void = " "
}

typealias Pos = Grid<WalkSpot>.Index
typealias Dir = Grid<WalkSpot>.Direction

enum Turn: String {
    case clockwise = "R"
    case ccw = "L"
}

extension Grid where Element == WalkSpot {
    // the flattened cube has to be 4x3, so the long side / 4 is the face length
    var cubeSize: Int { Swift.max(xSize, ySize) / 4 }
}

extension Collection where Element: Equatable {
    func eachPermutation(_ body: (Element, Element) -> Void) {
        for a in self {
            for b in self {
                guard a != b else { continue }
                body(a, b)
            }
        }
    }
}

class CubeFace: Equatable {
    let x: Int
    let y: Int
    let grid: Grid<WalkSpot>
    var exit: [Dir : (face: CubeFace, edge: Dir)] = [:]

    init(x: Int, y: Int, grid: Grid<WalkSpot>) {
        self.x = x
        self.y = y
        self.grid = grid
    }

    var minX: Int { x * grid.cubeSize }
    var maxX: Int { minX + grid.cubeSize - 1 }
    var minY: Int { y * grid.cubeSize }
    var maxY: Int { minY + grid.cubeSize - 1 }

    func contains(_ p: Pos) -> Bool {
        p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY
    }

    static func ==(lhs: CubeFace, rhs: CubeFace) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    static func findFacesFor(grid: Grid<WalkSpot>) -> [CubeFace] {
        var cubeFaces: [CubeFace] = []
        let size = grid.cubeSize
        for x in 0 ..< grid.xSize / size {
            for y in 0 ..< grid.ySize / size {
                guard grid[Pos(x: x * size, y: y * size)] != .void else { continue }
                cubeFaces.append(CubeFace(x: x, y: y, grid: grid))
            }
        }
        assert(cubeFaces.count == 6)

        // 'fold' faces, where they are already connected in the flat grid
        var connections = 0
        cubeFaces.eachPermutation { a, b in
            if a.y == b.y, b.x - a.x == 1 {
                a.exit[.right] = (b, .left)
                b.exit[.left] = (a, .right)
                connections += 2
            } else if a.x == b.x, b.y - a.y == 1 {
                a.exit[.down] = (b, .up)
                b.exit[.up] = (a, .down)
                connections += 2
            }
        }
        assert(connections == 10)

        // look for corners, where 3 faces are already connected in an L
        repeat {
            for a in cubeFaces {
                for d in Dir.allCases {
                    guard let (b, bEntry) = a.exit[d] else { continue }
                    if let (c, cEntry) = b.exit[bEntry.turnCCW()] {
                        guard a.exit[d.turnClockwise()] == nil else { continue }
                        a.exit[d.turnClockwise()] = (c, cEntry.turnCCW())
                        c.exit[cEntry.turnCCW()] = (a, d.turnClockwise())
                        connections += 2
                    }
                    if let (c, cEntry) = b.exit[bEntry.turnClockwise()] {
                        guard a.exit[d.turnCCW()] == nil else { continue }
                        a.exit[d.turnCCW()] = (c, cEntry.turnClockwise())
                        c.exit[cEntry.turnClockwise()] = (a, d.turnCCW())
                        connections += 2
                    }
                }
            }
        } while connections < 24

        return cubeFaces
    }
}

func wrappingMap(_ contents: String, part2: Bool = true) -> Int {
    // Split the input into map and instructions
    let parts = contents.components(separatedBy: "\n\n")
    assert(parts.count == 2)
    let grid = Grid(contents: parts[0]) { WalkSpot(rawValue: $0)! }
    let instructions = parts[1]

    let cubeFaces = CubeFace.findFacesFor(grid: grid)

    // Start at x= first non void, y = 0
    var position = Pos()
    for p in grid.rightFrom(y: 0) {
        if grid[p] == .empty {
            position = p
            break
        }
    }
    var facing = Dir.right

    // Parse the instructions
    let regex = Regex {
        ChoiceOf {
            Capture { OneOrMore(.digit) } transform: { Int($0)! }
            Capture { ChoiceOf { "L" ; "R" } } transform: { Turn(rawValue: String($0))! }
        }
    }
    let moves = instructions.matches(of: regex)

    // Given a position and direction you left a cube face, where do you end up?
    // (The direction you face is always away from the edge you entered on.)
    func cubeEntryPoint(_ p: Pos, _ direction: Dir) -> (Pos, Dir) {
        let source = cubeFaces.first(where: { $0.contains(p) })!
        let (dest, entrySide) = source.exit[direction]!
        let cubeSize = grid.cubeSize

        // the min and max coords for the destination cube face square
        let cubeMins = (x: dest.minX, y: dest.minY)
        let cubeMaxs = (x: dest.maxX, y: dest.maxY)

        // the origin coords from the original cube face
        let pX = p.x % cubeSize
        let pY = p.y % cubeSize

        let newP: Pos
        switch (direction, entrySide) {
        // Wrapping straight around (e.g. exit going left, enter on the right)
        // The coord you enter on is the same one you exited from.
        case (.left, .right): newP = Pos(x: cubeMaxs.x, y: cubeMins.y + pY)
        case (.right, .left): newP = Pos(x: cubeMins.x, y: cubeMins.y + pY)
        case (.up, .down): newP = Pos(x: cubeMins.x + pX, y: cubeMaxs.y)
        case (.down, .up): newP = Pos(x: cubeMins.x + pX, y: cubeMins.y)
        // The coord you enter on is mirror-image the one you exit from.
        case (.left, .left): newP = Pos(x: cubeMins.x, y: cubeMaxs.y - pY)
        case (.right, .right): newP = Pos(x: cubeMaxs.x, y: cubeMaxs.y - pY)
        case (.up, .up): newP = Pos(x: cubeMaxs.x - pX, y: cubeMins.y)
        case (.down, .down): newP = Pos(x: cubeMaxs.x - pX, y: cubeMaxs.y)
        // The same as the above cases but now involves swapping x and y in the coord you exit/enter.
        case (.left, .up): newP = Pos(x: cubeMins.x + pY, y: cubeMins.y)
        case (.right, .up): newP = Pos(x: cubeMaxs.x - pY, y: cubeMins.y)
        case (.left, .down): newP = Pos(x: cubeMaxs.x - pY, y: cubeMaxs.y)
        case (.right, .down): newP = Pos(x: cubeMins.x + pY, y: cubeMaxs.y)
        case (.up, .left): newP = Pos(x: cubeMins.x, y: cubeMins.y + pX)
        case (.down, .left): newP = Pos(x: cubeMins.x, y: cubeMaxs.y - pX)
        case (.up, .right): newP = Pos(x: cubeMaxs.x, y: cubeMaxs.y - pX)
        case (.down, .right): newP = Pos(x: cubeMaxs.x, y:  cubeMins.y + pX)
        }
        return (newP, entrySide.opposite())
    }

    // Take one step, doing wrapping as necessary.
    func wrappedStep(_ p: Pos, _ direction: Dir) -> (Pos, Dir) {
        var newP = p.direction(direction)

        if part2 {
            if grid.valid(index: newP), grid[newP] != .void {
                return (newP, direction)
            }
            return cubeEntryPoint(p, direction)
        } else {
            guard !grid.valid(index: newP) else { return (newP, direction) }

            switch direction {
            case .left: newP = Pos(x: grid.xSize-1, y: p.y)
            case .right: newP = Pos(x: 0, y: p.y)
            case .up: newP = Pos(x: p.x, y: grid.ySize-1)
            case .down: newP = Pos(x: p.x, y: 0)
            }
            return (newP, direction)
        }
    }

    // Make the actual moves, and keep going in a straight line through void.
    // (In part2 the wrappedStep() will never return a void spot, so the while loop is never used.)
    for move in moves {
        if let forward = move.output.1 {
            for _ in 0 ..< forward {
                var face = facing
                var step = position
                (step, face) = wrappedStep(step, face)
                while grid[step] == .void {
                    (step, face) = wrappedStep(step, face)
                }
                if grid[step] == .empty {
                    position = step
                    facing = face
                }
            }
        } else {
            switch move.output.2! {
            case .clockwise:
                facing = facing.turnClockwise()
            case .ccw:
                facing = facing.turnCCW()
            }
        }
    }

    // Encoding the end position and facing
    let facingValue: Int
    switch facing {
    case .left: facingValue = 2
    case .right: facingValue = 0
    case .up: facingValue = 3
    case .down: facingValue = 1
    }
    return 1000 * (position.y+1) + 4 * (position.x+1) + facingValue
}
