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

/// A closure type that takes a closure as its parameter.
public typealias OperationBlock = (Void -> Void) -> Void

/// A sublcass of `Operation` to execute a closure.
public class BlockOperation: Operation {
    private let block: OperationBlock?
    
    /**
        The designated initializer.
        
        - parameter block: The closure to run when the operation executes. This 
            closure will be run on an arbitrary queue. The parameter passed to the
            block **MUST** be invoked by your code, or else the `BlockOperation`
            will never finish executing. If this parameter is `nil`, the operation
            will immediately finish.
    */
    public init(block: OperationBlock? = nil) {
        self.block = block
        super.init()
    }
    
    /**
        A convenience initializer to execute a block on the main queue.
        
        - parameter mainQueueBlock: The block to execute on the main queue. Note
            that this block does not have a "continuation" block to execute (unlike
            the designated initializer). The operation will be automatically ended 
            after the `mainQueueBlock` is executed.
    */
    public convenience init(mainQueueBlock: dispatch_block_t) {
        self.init(block: { continuation in
            dispatch_async(dispatch_get_main_queue()) {
                mainQueueBlock()
                continuation()
            }
        })
    }
    
    override public func execute() {
        if let block = block {
            block {
                self.finish()
            }
        } else {
            finish()
        }
    }
}
