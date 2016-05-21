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
    A condition that specifies that every dependency must have succeeded.
    If any dependency was cancelled, the target operation will be cancelled as 
    well.
*/
public struct NoCancelledDependencies: OperationCondition {
    public static let name = "NoCancelledDependencies"
    static let cancelledDependenciesKey = "CancelledDependencies"
    public static let isMutuallyExclusive = false
    
    public init() {
        // No op.
    }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        // Verify that all of the dependencies executed.
        let cancelled = operation.dependencies.filter { $0.cancelled }

        if !cancelled.isEmpty {
            // At least one dependency was cancelled; the condition was not satisfied.
            let error = NSError(code: .ConditionFailed, userInfo: [
                OperationConditionKey: self.dynamicType.name,
                self.dynamicType.cancelledDependenciesKey: cancelled
            ])
            
            completion(.Failed(error))
        }
        else {
            completion(.Satisfied)
        }
    }
}
