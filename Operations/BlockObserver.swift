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
    The `BlockObserver` is a way to attach arbitrary blocks to significant events 
    in an `Operation`'s lifecycle.
*/
public struct BlockObserver: OperationObserver {
    // MARK: Properties
    
    private let startHandler: (Operation -> Void)?
    private let cancelHandler: (Operation -> Void)?
    private let produceHandler: ((Operation, NSOperation) -> Void)?
    private let finishHandler: ((Operation, [NSError]) -> Void)?
    
    public init(startHandler: (Operation -> Void)? = nil, cancelHandler: (Operation -> Void)? = nil, produceHandler: ((Operation, NSOperation) -> Void)? = nil, finishHandler: ((Operation, [NSError]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.cancelHandler = cancelHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperationObserver
    
    public func operationDidStart(operation: Operation) {
        startHandler?(operation)
    }
    
    public func operationDidCancel(operation: Operation) {
        cancelHandler?(operation)
    }
    
    public func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        produceHandler?(operation, newOperation)
    }
    
    public func operationDidFinish(operation: Operation, errors: [NSError]) {
        finishHandler?(operation, errors)
    }
}
