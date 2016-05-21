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

/// A generic condition for describing kinds of operations that may not execute concurrently.
public struct MutuallyExclusive<T>: OperationCondition {
    public static var name: String {
        return "MutuallyExclusive<\(T.self)>"
    }

    public static var isMutuallyExclusive: Bool {
        return true
    }
    
    public init() { }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        completion(.Satisfied)
    }
}

/**
    The purpose of this enum is to simply provide a non-constructible
    type to be used with `MutuallyExclusive<T>`.
*/
public enum Alert { }

/// A condition describing that the targeted operation may present an alert.
public typealias AlertPresentation = MutuallyExclusive<Alert>
