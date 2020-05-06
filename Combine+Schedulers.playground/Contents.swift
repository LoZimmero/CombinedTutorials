
import Foundation
import Combine


// Syncronous DispatchQueue
let aQueue = DispatchQueue(label: "serial")
let anotherQueue = DispatchQueue(label: "serial again")

//To see in what thread we are:
print("Now we are in thread \(Thread.current)")
let s = [1, 2, 3, 4, 5].publisher
    .subscribe(on: aQueue)
    .sink(receiveValue: {
        print("Recieved \($0) on thread \(Thread.current)")
    })


//MARK: - ImmediateScheduler
// Refer to the shared ImmediateScheduler
let immediateScheduler = ImmediateScheduler.shared

// Create a simple publisher and subscription
let aPublisher = [1, 2, 3, 4, 5].publisher
    //.receive(on: immediateScheduler)
    .receive(on: DispatchQueue.global())
    .sink(receiveValue: {
    print("Recieved \($0) on thread \(Thread.current)")
})


//MARK: - RunLoop
let bPublisher = [1, 2, 3, 4, 5].publisher
    .receive(on: RunLoop.current)
    .sink(receiveValue: {
    print("Recieved \($0) on thread \(Thread.current)")
})


//MARK: - DispatchQueue
// Main Queue
let mainQueue = DispatchQueue.main
// A serial queue
let someSerialQueue = DispatchQueue(label: "serial")
// A parallel queue
let someParallelQueue = DispatchQueue(label: "parallel", attributes: .concurrent)

// Subscription to publisher
let cPublisher = [1, 2, 3, 4, 5].publisher
    .receive(on: someParallelQueue)
    .sink(receiveValue: {
    print("Recieved \($0) on thread \(Thread.current)")
})

//MARK: - OperationQueue
let opQueue = OperationQueue()

// Only an operation per time
opQueue.maxConcurrentOperationCount = 1

let sub = [1, 2, 3, 4, 5].publisher
    .receive(on: opQueue)
    .sink(receiveValue: {
    print("Recieved \($0) on thread \(Thread.current)")
})
