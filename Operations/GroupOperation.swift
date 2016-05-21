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
    A subclass of `Operation` that executes zero or more operations as part of its
    own execution. This class of operation is very useful for abstracting several 
    smaller operations into a larger operation. As an example, the `GetEarthquakesOperation`
    is composed of both a `DownloadEarthquakesOperation` and a `ParseEarthquakesOperation`.

    Additionally, `GroupOperation`s are useful if you establish a chain of dependencies, 
    but part of the chain may "loop". For example, if you have an operation that
    requires the user to be authenticated, you may consider putting the "login" 
    operation inside a group operation. That way, the "login" operation may produce
    subsequent operations (still within the outer `GroupOperation`) that will all
    be executed before the rest of the operations in the initial chain of operations.
*/
public class GroupOperation: Operation {
    private let internalQueue = OperationQueue()
    private let startingOperation = NSBlockOperation(block: {})
    private let finishingOperation = NSBlockOperation(block: {})

    private var aggregatedErrors = [NSError]()
    
    public convenience init(operations: NSOperation...) {
        self.init(operations: operations)
    }
    
    public init(operations: [NSOperation]) {
        super.init()
        
        internalQueue.suspended = true
        internalQueue.delegate = self
        internalQueue.addOperation(startingOperation)
        
        for operation in operations {
            internalQueue.addOperation(operation)
        }
    }
    
    override public func cancel() {
        internalQueue.cancelAllOperations()
        internalQueue.suspended = false
        super.cancel()
    }
    
    override public func execute() {
        internalQueue.suspended = false
        internalQueue.addOperation(finishingOperation)
    }
    
    public func addOperation(operation: NSOperation) {
        internalQueue.addOperation(operation)
    }
    
    /**
        Note that some part of execution has produced an error.
        Errors aggregated through this method will be included in the final array 
        of errors reported to observers and to the `finished(_:)` method.
    */
    public final func aggregateError(error: NSError) {
        aggregatedErrors.append(error)
    }
    
    public func operationDidFinish(operation: NSOperation, withErrors errors: [NSError]) {
        // For use by subclassers.
    }
}

extension GroupOperation: OperationQueueDelegate {
    final public func operationQueue(operationQueue: OperationQueue, willAddOperation operation: NSOperation) {
        assert(!finishingOperation.finished && !finishingOperation.executing, "cannot add new operations to a group after the group has completed")
        
        /*
            Some operation in this group has produced a new operation to execute.
            We want to allow that operation to execute before the group completes,
            so we'll make the finishing operation dependent on this newly-produced operation.
        */
        if operation !== finishingOperation {
            finishingOperation.addDependency(operation)
        }
        
        /*
        All operations should be dependent on the "startingOperation".
        This way, we can guarantee that the conditions for other operations
        will not evaluate until just before the operation is about to run.
        Otherwise, the conditions could be evaluated at any time, even
        before the internal operation queue is unsuspended.
        */
        if operation !== startingOperation {
            operation.addDependency(startingOperation)
        }

    }
    
    final public func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [NSError]) {
        aggregatedErrors.appendContentsOf(errors)
        
        if operation === finishingOperation {
            internalQueue.suspended = true
            finish(aggregatedErrors)
        }
        else if operation !== startingOperation {
            operationDidFinish(operation, withErrors: errors)
        }
    }
}
