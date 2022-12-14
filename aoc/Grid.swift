//
//  Grid.swift
//  aoc
//
//  Created by Greg Titus on 12/8/22.
//

import Foundation

class Grid<Element> : Collection, Sequence {
    var elements: [[Element]] = []

    init() {}

    convenience init(contents: String, mapping: @escaping (Character) -> Element) {
        self.init()

        var map: [[Element]] = []
        contents.enumerateLines { line, _ in
            map.append(line.map(mapping))
        }
        elements = map
    }

    var xSize: Int { elements.first?.count ?? 0 }
    var ySize: Int { elements.count }

    subscript(i: Index) -> Element {
        get {
            elements[i.y][i.x]
        }
        set {
            elements[i.y][i.x] = newValue
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

    enum Direction: CaseIterable {
        case left
        case right
        case up
        case down
    }

    func cardinalDirections(from: Index) -> [Index] {
        Direction.allCases.map({ from.direction($0) }).filter { valid(index: $0) }
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

    struct Index : Hashable, Comparable {
        let x: Int
        let y: Int

        init(x: Int = 0, y: Int = 0) {
            self.x = x
            self.y = y
        }

        static func < (lhs: Grid<Element>.Index, rhs: Grid<Element>.Index) -> Bool {
            if lhs.y < rhs.y { return true }
            if lhs.y > rhs.y { return false }
            return lhs.x < rhs.x
        }

        func direction(_ d: Direction) -> Index {
            switch d {
            case .left: return Index(x: x-1, y: y)
            case .right: return Index(x: x+1, y: y)
            case .up: return Index(x: x, y: y-1)
            case .down: return Index(x: x, y: y+1)
            }
        }

        func direction(to: Self) -> Direction {
            if x > to.x { return .left }
            if x < to.x { return .right }
            if y > to.y { return .up }
            return .down
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

        // Sequence protocol
        func makeIterator() -> Self { return self }
        var underestimatedCount: Int { return 0 }
        func withContiguousStorageIfAvailable<R>(_ body: (_ buffer: UnsafeBufferPointer<Self.Element>) throws -> R) rethrows -> R? {
            return nil
        }

        // Iterator protocol
        mutating func next() -> Index? {
            guard grid.valid(index: current) else { return nil }
            let result = current
            current = move(current)
            return result
        }
    }

    func walk(_ direction: Direction, from: Index) -> PositionSequence {
        let move: (Index) -> Index = { $0.direction(direction) }
        return PositionSequence(grid: self, current: move(from), move: move)
    }

    func leftFrom(x: Int? = nil, y: Int) -> PositionSequence {
        PositionSequence(grid: self, current: Index(x: x ?? xSize-1, y: y), move: { $0.direction(.left) })
    }
    func rightFrom(x: Int? = nil, y: Int) -> PositionSequence {
        PositionSequence(grid: self, current: Index(x: x ?? 0, y: y), move: { $0.direction(.right) })
    }
    func upFrom(x: Int, y: Int? = nil) -> PositionSequence {
        PositionSequence(grid: self, current: Index(x: x, y: y ?? 0), move: { $0.direction(.up) })
    }
    func downFrom(x: Int, y: Int? = nil) -> PositionSequence {
        PositionSequence(grid: self, current: Index(x: x, y: y ?? ySize-1), move: { $0.direction(.down) })
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

