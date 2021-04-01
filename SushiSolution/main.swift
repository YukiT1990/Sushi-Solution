//
//  main.swift
//  SushiSolution
//
//  Created by Yuki Tsukada on 2021/04/01.
//

import Foundation

public final class Queue<E> : Sequence {
    /// beginning of queue
    private var first: Node<E>? = nil
    /// end of queue
    private var last: Node<E>? = nil
    /// size of the queue
    private(set) var count: Int = 0
    
    /// helper linked list node class
    fileprivate class Node<E> {
        fileprivate var item: E
        fileprivate var next: Node<E>?
        fileprivate init(item: E, next: Node<E>? = nil) {
            self.item = item
            self.next = next
        }
    }
    
    /// Initializes an empty queue.
    public init() {}
    
    /// Returns true if this queue is empty.
    public func isEmpty() -> Bool {
        return first == nil
    }
    
    /// Returns the item least recently added to this queue.
    public func peek() -> E? {
        return first?.item
    }
    
    /// Adds the item to this queue
    /// - Parameter item: the item to add
    public func enqueue(item: E) {
        let oldLast = last
        last = Node<E>(item: item)
        if isEmpty() { first = last }
        else { oldLast?.next = last }
        count += 1
    }
    
    /// Removes and returns the item on this queue that was least recently added.
    public func dequeue() -> E? {
        if let item = first?.item {
            first = first?.next
            count -= 1
            // to avoid loitering
            if isEmpty() { last = nil }
            return item
        }
        return nil
    }
    
    /// QueueIterator that iterates over the items in FIFO order.
    public struct QueueIterator<E> : IteratorProtocol {
        private var current: Node<E>?
        
        fileprivate init(_ first: Node<E>?) {
            self.current = first
        }
        
        public mutating func next() -> E? {
            if let item = current?.item {
                current = current?.next
                return item
            }
            return nil
        }
        
        public typealias Element = E
    }
    
    /// Returns an iterator that iterates over the items in this Queue in FIFO order.
    public __consuming func makeIterator() -> QueueIterator<E> {
        return QueueIterator<E>(first)
    }
}

extension Queue: CustomStringConvertible {
    public var description: String {
        return self.reduce(into: "") { $0 += "\($1) " }
    }
}


func solution() {
    struct Restaurant {
        let number: Int
        let previousRestaurant: Int
        let traveledRestaurants: Set<Int>
        let travelTime: Int
    }
    
    let firstLine = readLine()!.split(separator: " ").map { Int($0) }
    let numOfN = firstLine[0]!
    let indexesOfM: [Int] = readLine()!.split(separator: " ").map { Int($0)! }
    
    var smallestTravelTime = 2 * numOfN
    let emptySet: Set<Int> = []
    
    var paths = [[Int]](repeating: [Int](repeating: 0, count: 0), count: numOfN)
    
    
    for _ in 1..<numOfN {
        let pathInput = readLine()!.split(separator: " ").map { Int($0) }
        paths[pathInput[0]!].append(pathInput[1]!)
        paths[pathInput[1]!].append(pathInput[0]!)
    }
    
    func findSmallestTravelTime(startRestaurant: Restaurant) {
        let q = Queue<Restaurant>()
        q.enqueue(item: startRestaurant)
        var numberOfTimesPassed = [Int](repeating: 0, count: numOfN)
        
        while !q.isEmpty() {
            let sq = q.dequeue()!
            let number = sq.number
            let adjacentRestaurants: [Int] = paths[number]
            let previousReataurant: Int = sq.previousRestaurant
            var traveledRestaurants: Set<Int> = sq.traveledRestaurants
            let travelTime = sq.travelTime
            traveledRestaurants.insert(number)
            numberOfTimesPassed[number] += 1
            
            if travelTime > smallestTravelTime {
                break
            }
            if containsAll(array: indexesOfM, set: traveledRestaurants) {
                if travelTime < smallestTravelTime {
                    smallestTravelTime = travelTime
                }
                break
            }

            for i in 0..<adjacentRestaurants.count {
                let adjacentRestaurantNumber = adjacentRestaurants[i]
                if adjacentRestaurantNumber == previousReataurant && adjacentRestaurants.count > 1 {
                    continue
                }
                if numberOfTimesPassed[i] > paths[i].count {
                    continue
                }
                q.enqueue(item: Restaurant(number: adjacentRestaurantNumber, previousRestaurant: number, traveledRestaurants: traveledRestaurants, travelTime: travelTime + 1))
            }
        }
    }
    for restaurant in indexesOfM {
        findSmallestTravelTime(startRestaurant: Restaurant(number: restaurant, previousRestaurant: -1, traveledRestaurants: emptySet, travelTime: 0))
    }
    print(smallestTravelTime)
}

func containsAll(array: [Int], set: Set<Int>) -> Bool {
    for i in array {
        if !set.contains(i) {
            return false
        }
    }
    return true
}


solution()
