//
//  Snowverload.swift
//  aoc
//
//  Created by Greg Titus on 12/26/23.
//

import Foundation

func snowverload(_ contents: String) -> Int {
    struct Component {
        let name: String
        var connect: [String]
    }
    var components: [String : Component] = [:]

    contents.enumerateLines { line, _ in
        let parts = line.components(separatedBy: ":")
        let name = parts[0]
        var connect = parts[1].components(separatedBy: " ").filter({ $0.count == 3})

        if let c = components[name] {
            connect.append(contentsOf: c.connect)
        }
        components[name] = Component(name: name, connect: connect)

        for n in connect {
            var connect = [name]
            if let c = components[n] {
                connect.append(contentsOf: c.connect)
            }
            components[n] = Component(name: n, connect: connect)
        }
    }

    let allComponents = Array(components.values)
    var edges = Set<Edge>()
    for i in allComponents.indices {
        let component = allComponents[i]
        for to in component.connect {
            let j = allComponents.firstIndex(where: {$0.name == to})!
            let edge = Edge(a: min(i,j), b: max(i,j))
            guard !edges.contains(edge) else { continue }
            edges.insert(edge)
        }
    }
    let edgeArray = Array(edges)

    struct Edge: Hashable {
        let a: Int
        let b: Int
    }

    func kargers(vertices start: Int, edges: [Edge]) -> [Edge] {
        struct Subset: Equatable {
            var parent: Int
            var rank: Int
        }

        var vertices = start
        var subsets: [Subset] = (0 ..< vertices).map { Subset(parent: $0, rank: 0) }

        func find(_ i: Int) -> Int {
            if subsets[i].parent != i {
                subsets[i].parent = find(subsets[i].parent)
            }
            return subsets[i].parent
        }

        func union(_ xroot: Int, _ yroot: Int) {
            if subsets[xroot].rank < subsets[yroot].rank {
                subsets[xroot].parent = yroot
            } else if subsets[xroot].rank > subsets[yroot].rank {
                subsets[yroot].parent = xroot
            } else {
                subsets[yroot].parent = xroot
                subsets[xroot].rank += 1
            }
        }

        while vertices > 2 {
            let e = edges.randomElement()!
            let (subset1, subset2) = (find(e.a), find(e.b))

            if subset1 != subset2 {
                vertices -= 1
                union(subset1, subset2)
            }
        }
        return edges.filter { find($0.a) != find($0.b) }
    }

    struct StringEdge: Equatable {
        let a: String
        let b: String
    }

    func reach(start: String, ignore: [StringEdge], reached: inout Set<String>) {
        reached.insert(start)
        for to in components[start]!.connect {
            guard !reached.contains(to) else { continue }
            let edge = StringEdge(a: min(start, to), b: max(start, to))
            if ignore.first(where: { $0 == edge }) == nil {
                reach(start: to, ignore: ignore, reached: &reached)
            }
        }
    }

    var cutEdges: [Edge] = []
    while cutEdges.count != 3 {
        cutEdges = kargers(vertices: allComponents.count, edges: edgeArray)
    }
    let stringEdges = cutEdges.map {
        let n1 = allComponents[$0.a].name
        let n2 = allComponents[$0.b].name
        return StringEdge(a: min(n1,n2), b: max(n1,n2))
    }
    var reached = Set<String>()
    reach(start: allComponents[0].name, ignore: stringEdges, reached: &reached)
    return reached.count * (allComponents.count - reached.count)
}
