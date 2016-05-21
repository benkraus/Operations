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
    `TimeoutObserver` is a way to make an `Operation` automatically time out and 
    cancel after a specified time interval.
*/
public struct TimeoutObserver: OperationObserver {
    // MARK: Properties

    static let timeoutKey = "Timeout"
    
    private let timeout: NSTimeInterval
    
    // MARK: Initialization
    
    public init(timeout: NSTimeInterval) {
        self.timeout = timeout
    }
    
    // MARK: OperationObserver
    
    public func operationDidStart(operation: Operation) {
        // When the operation starts, queue up a block to cause it to time out.
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(timeout * Double(NSEC_PER_SEC)))

        dispatch_after(when, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            /*
                Cancel the operation if it hasn't finished and hasn't already 
                been cancelled.
            */
            if !operation.finished && !operation.cancelled {
                let error = NSError(code: .ExecutionFailed, userInfo: [
                    self.dynamicType.timeoutKey: self.timeout
                ])

                operation.cancelWithError(error)
            }
        }
    }
    
    public func operationDidCancel(operation: Operation) {
        // No op.
    }

    public func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        // No op.
    }

    public func operationDidFinish(operation: Operation, errors: [NSError]) {
        // No op.
    }
}
