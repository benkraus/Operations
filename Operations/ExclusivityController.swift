/*
 The MIT License (MIT)

 Original work Copyright (c) 2015 pluralsight
 Modified work Copyright 2016 Ben Kraus

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

/**
    `ExclusivityController` is a singleton to keep track of all the in-flight
    `Operation` instances that have declared themselves as requiring mutual exclusivity. 
    We use a singleton because mutual exclusivity must be enforced across the entire
    app, regardless of the `OperationQueue` on which an `Operation` was executed.
*/
class ExclusivityController {
    static let sharedExclusivityController = ExclusivityController()
    
    private let serialQueue = dispatch_queue_create("Operations.ExclusivityController", DISPATCH_QUEUE_SERIAL)
    private var operations: [String: [Operation]] = [:]
    
    private init() {
        /*
            A private initializer effectively prevents any other part of the app
            from accidentally creating an instance.
        */
    }
    
    /// Registers an operation as being mutually exclusive
    func addOperation(operation: Operation, categories: [String]) {
        /*
            This needs to be a synchronous operation.
            If this were async, then we might not get around to adding dependencies 
            until after the operation had already begun, which would be incorrect.
        */
        dispatch_sync(serialQueue) {
            for category in categories {
                self.noqueue_addOperation(operation, category: category)
            }
        }
    }
    
    /// Unregisters an operation from being mutually exclusive.
    func removeOperation(operation: Operation, categories: [String]) {
        dispatch_async(serialQueue) {
            for category in categories {
                self.noqueue_removeOperation(operation, category: category)
            }
        }
    }
    
    
    // MARK: Operation Management
    
    private func noqueue_addOperation(operation: Operation, category: String) {
        var operationsWithThisCategory = operations[category] ?? []
        
        if let last = operationsWithThisCategory.last {
            operation.addDependency(last)
        }
        
        operationsWithThisCategory.append(operation)

        operations[category] = operationsWithThisCategory
    }
    
    private func noqueue_removeOperation(operation: Operation, category: String) {
        let matchingOperations = operations[category]

        if var operationsWithThisCategory = matchingOperations,
           let index = operationsWithThisCategory.indexOf(operation) {

            operationsWithThisCategory.removeAtIndex(index)
            operations[category] = operationsWithThisCategory
        }
    }
    
}
