//
//  Grid.swift
//  aoc
//
//  Created by Greg Titus on 12/8/22.
//

import Foundation

enum Direction: Int, CaseIterable {
    case left = 0
    case right = 1
    case up = 2
    case down = 3

    var dx: Int {
        switch self {
        case .left: -1
        case .right: 1
        default: 0
        }
    }

    var dy: Int {
        switch self {
        case .up: -1
        case .down: 1
        default: 0
        }
    }

    var horizontal: Bool { dx != 0 }
    var vertical: Bool { dy != 0 }

    func turnClockwise() -> Direction {
        switch self {
        case .left: return .up
        case .right: return .down
        case .up: return .right
        case .down: return .left
        }
    }

    func turnCCW() -> Direction {
        switch self {
        case .left: return .down
        case .right: return .up
        case .up: return .left
        case .down: return .right
        }
    }

    func opposite() -> Direction {
        return self.turnClockwise().turnClockwise()
    }
}

struct Position : Hashable, Comparable {
    let x: Int
    let y: Int

    init(x: Int = 0, y: Int = 0) {
        self.x = x
        self.y = y
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.y < rhs.y { return true }
        if lhs.y > rhs.y { return false }
        return lhs.x < rhs.x
    }

    func direction(_ d: Direction) -> Self { Self(x: x+d.dx, y: y+d.dy) }

    func vector(dx: Int, dy: Int) -> Self { Self(x: x+dx, y: y+dy) }

    func direction(to: Self) -> Direction {
        if x > to.x { return .left }
        if x < to.x { return .right }
        if y > to.y { return .up }
        return .down
    }

    func wrap<E>(in grid: Grid<E>) -> Self {
        var x = self.x % grid.xSize
        var y = self.y % grid.ySize
        if x < 0 { x += grid.xSize }
        if y < 0 { y += grid.ySize }
        return grid.at(x: x, y: y)
    }
}

class Grid<Element> : Collection, Sequence {
    let width: Int
    let height: Int
    var elements: [Element]

    init(width: Int, height: Int, elements: [Element]) {
        self.width = width
        self.height = height
        self.elements = elements
    }

    convenience init(copy grid: Grid) {
        self.init(width: grid.xSize, height: grid.ySize, elements: grid.elements)
    }

    convenience init(contents: String, makeSameWidth: Bool = false, mapping: @escaping (Character) -> Element) {
        var lines = contents.components(separatedBy: "\n")
        let max = lines.map({ $0.count }).max()!
        if makeSameWidth {
            for i in lines.indices {
                lines[i].append(String(repeating: " ", count: max - lines[i].count))
            }
        }

        var map: [Element] = []
        var empty = 0
        for line in lines {
            guard !line.isEmpty else {
                empty += 1
                continue
            }
            map.append(contentsOf: line.map(mapping))
        }
        self.init(width: max, height: lines.count - empty, elements: map)
    }

    convenience init(width: Int, height: Int, element: Element) {
        self.init(width: width, height: height, elements: Array(repeating: element, count: width*height))
    }

    var xSize: Int { width }
    var ySize: Int { height }

    typealias Index = Position
    subscript(i: Index) -> Element {
        get {
            elements[i.y * width + i.x]
        }
        set {
            elements[i.y * width + i.x] = newValue
        }
    }

    var startIndex: Index { return Index(x: 0, y: 0) }
    var endIndex: Index { return Index(x:0, y: ySize) }

    func index(after i: Index) -> Index {
        i.x < xSize-1 ? Index(x: i.x+1, y: i.y) : Index(x: 0, y: i.y+1)
    }

    func valid(index: Index) -> Bool {
        index.x >= 0 && index.x < xSize && index.y >= 0 && index.y < ySize
    }


    func cardinalDirections(from: Index) -> [Index] {
        Direction.allCases.map({ from.direction($0) }).filter { valid(index: $0) }
    }

    func diagonalAdjacencies(from: Index) -> [Index] {
        var result: [Index] = []
        for x in [from.x-1, from.x, from.x+1] {
            for y in [from.y-1, from.y, from.y+1] {
                let index = Index(x: x, y: y)
                if index != from, valid(index: index) {
                    result.append(index)
                }
            }
        }
        return result
    }

    struct Iterator: IteratorProtocol {
        let grid: Grid
        var i = Index()

        mutating func next() -> Element? {
            guard i.y < grid.ySize else { return nil }
            let result = grid[i]
            i = grid.index(after: i)
            return result
        }
    }

    func makeIterator() -> Iterator { Iterator(grid: self) }

    func at(x: Int, y: Int) -> Index { Index(x: x, y: y) }
    subscript(x: Int, y: Int) -> Element {
        get {
            elements[y * width + x]
        }
        set {
            elements[y * width + x] = newValue
        }
    }

    // Needed this for Collection conformance, but completely untested
    struct IndexRange : RangeExpression {
        let lowerBound: Index
        let upperBound: Index

        func relative<C>(to collection: C) -> Range<Index> where C : Collection, Index == C.Index {
            return lowerBound ..< upperBound
        }

        func contains(_ element: Index) -> Bool {
            element.x >= lowerBound.x && element.y >= lowerBound.y && element.x < upperBound.x && element.y < upperBound.y
        }
    }

    struct PositionSequence: Sequence, IteratorProtocol {
        var grid: Grid
        var current: Index
        let move: (Index) -> Index

        mutating func next() -> Index? {
            guard grid.valid(index: current) else { return nil }
            let result = current
            current = move(current)
            return result
        }

        func elements() -> ElementSequence { ElementSequence(ps: self) }
    }

    struct ElementSequence: Sequence, IteratorProtocol {
        var ps: PositionSequence

        mutating func next() -> Element? {
            guard let i = ps.next() else { return nil }
            return ps.grid[i]
        }
    }


    func walk(_ direction: Direction, from: Index) -> PositionSequence {
        let move: (Index) -> Index = { $0.direction(direction) }
        return PositionSequence(grid: self, current: move(from), move: move)
    }

    func walk(dx: Int, dy: Int, from: Index) -> PositionSequence {
        let move: (Index) -> Index = { $0.vector(dx: dx, dy: dy) }
        return PositionSequence(grid: self, current: move(from), move: move)
    }

    func leftFrom(x: Int? = nil, y: Int) -> PositionSequence {
        PositionSequence(grid: self, current: Index(x: x ?? xSize-1, y: y), move: { $0.direction(.left) })
    }
    func rightFrom(x: Int? = nil, y: Int) -> PositionSequence {
        PositionSequence(grid: self, current: Index(x: x ?? 0, y: y), move: { $0.direction(.right) })
    }
    func upFrom(x: Int, y: Int? = nil) -> PositionSequence {
        PositionSequence(grid: self, current: Index(x: x, y: y ?? ySize-1), move: { $0.direction(.up) })
    }
    func downFrom(x: Int, y: Int? = nil) -> PositionSequence {
        PositionSequence(grid: self, current: Index(x: x, y: y ?? 0), move: { $0.direction(.down) })
    }
}

extension Grid: Equatable where Element: Equatable {
    static func == (lhs: Grid<Element>, rhs: Grid<Element>) -> Bool {
        lhs.elements == rhs.elements
    }
}

extension Grid: Hashable where Element: Hashable {
    func hash(into hasher: inout Hasher) {
        elements.hash(into: &hasher)
    }
}

import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

extension Grid {
    func bitmap(url: URL, pixelSize: Int = 1, transform: (Element) -> (CGFloat,CGFloat,CGFloat)) {
        let space = CGColorSpace(name: CGColorSpace.genericRGBLinear)!
        let context = CGContext(data: nil, width: xSize * pixelSize, height: ySize * pixelSize, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!
        let size = CGSize(width: pixelSize, height: pixelSize)
        for i in self.indices {
            let (r,g,b) = transform(self[i])
            context.setFillColor(red: r, green: g, blue: b, alpha: 1.0)
            context.fill([CGRect(origin: CGPoint(x: Double(i.x * pixelSize) - 0.5, y: Double((ySize - 1 - i.y) * pixelSize) - 0.5), size: size)])
        }
        let image = context.makeImage()!
        let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }
}

extension Grid {
    func printGrid(_ f: (Element) -> Character) {
        for y in 0 ..< ySize {
            var string = ""
            for x in 0 ..< xSize {
                string.append(f(self[x,y]))
            }
            print(string)
        }
    }
}

extension Grid where Element == Character {
    func printGrid() {
        printGrid({$0})
    }
    convenience init(contents: String, makeSameWidth: Bool = false) {
        self.init(contents: contents, makeSameWidth: makeSameWidth, mapping: {$0})
    }
}

