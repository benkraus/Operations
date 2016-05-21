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
    A simple condition that causes another condition to not enqueue its dependency.
    This is useful (for example) when you want to verify that you have access to 
    the user's location, but you do not want to prompt them for permission if you 
    do not already have it.
*/
public
struct SilentCondition<T: OperationCondition>: OperationCondition {
    let condition: T
    
    public static var name: String {
        return "Silent<\(T.name)>"
    }
    
    public static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }
    
    public init(condition: T) {
        self.condition = condition
    }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        // Returning nil means we will never a dependency to be generated.
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        condition.evaluateForOperation(operation, completion: completion)
    }
}
