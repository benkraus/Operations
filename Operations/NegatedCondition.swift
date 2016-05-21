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
    A simple condition that negates the evaluation of another condition.
    This is useful (for example) if you want to only execute an operation if the 
    network is NOT reachable.
*/
public struct NegatedCondition<T: OperationCondition>: OperationCondition {
    public static var name: String { 
        return "Not<\(T.name)>"
    }
    
    static var negatedConditionKey: String { 
        return "NegatedCondition"
    }
    
    public static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }
    
    let condition: T

    public init(condition: T) {
        self.condition = condition
    }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return condition.dependencyForOperation(operation)
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        condition.evaluateForOperation(operation) { result in
            switch result {
            case .Failed(_):
                // If the composed condition failed, then this one succeeded.
                completion(.Satisfied)
            case .Satisfied:
                // If the composed condition succeeded, then this one failed.
                let error = NSError(code: .ConditionFailed, userInfo: [
                    OperationConditionKey: self.dynamicType.name,
                    self.dynamicType.negatedConditionKey: self.condition.dynamicType.name
                    ])
                
                completion(.Failed(error))
            }
        }
    }
}
