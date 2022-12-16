//
//  Graph.swift
//  aoc
//
//  Created by Greg Titus on 12/16/22.
//

import Foundation

class DirectedGraph<Element : Identifiable> where Element.ID : Hashable {
    struct Node {
        let element: Element
        var edges: [Element.ID : Int]
    }
    private var nodes: [Element.ID : Node] = [:]

    var allNodes: [Element] {
        nodes.values.map { $0.element }
    }

    subscript(id: Element.ID) -> Element? {
        get {
            nodes[id]?.element
        }
        set {
            if let new = newValue {
                let edges = nodes[id]?.edges ?? [:]
                nodes[id] = Node(element: new, edges: edges)
            } else {
                removeNode(id: id)
           }
        }
    }

    func edges(_ id: Element.ID) -> [Element.ID : Int] {
        nodes[id]?.edges ?? [:]
    }

    func edgeCost(_ from: Element.ID, _ to: Element.ID) -> Int {
        nodes[from]?.edges[to] ?? 0
    }

    func addNode(_ e: Element) {
        nodes[e.id] = Node(element: e, edges: [:])
    }

    func addEdge(from: Element.ID, to: Element.ID, cost: Int = 1) {
        nodes[from]!.edges[to] = cost
    }

    func removeNode(id: Element.ID) {
        for from in nodes.keys {
            nodes[from]!.edges[id] = nil
        }
        nodes[id] = nil
    }
    
    func remove(where test: @escaping (Element) -> Bool) {
        let ids = nodes.values.lazy.filter({ test($0.element) }).map({ $0.element.id })
        ids.forEach { removeNode(id: $0) }
    }

    func isValid() -> Bool {
        for node in nodes.values {
            if node.edges.first(where: { nodes[$0.key] == nil }) != nil {
                return false
            }
        }
        return true
    }

    func fullyConnect() {
        var progress: Bool
        repeat {
            progress = false
            for origin in nodes.keys {
                let node = nodes[origin]!
                for edge1 in node.edges {
                    let midpoint = nodes[edge1.key]!
                    for edge2 in midpoint.edges {
                        let destination = edge2.key
                        guard origin != destination else { continue }
                        let distance = edge1.value + edge2.value
                        if node.edges[destination] == nil || node.edges[destination]! > distance {
                            nodes[origin]!.edges[destination] = distance
                            progress = true
                        }
                    }
                }
            }
        } while progress
    }

}
