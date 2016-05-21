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
    `DelayOperation` is an `Operation` that will simply wait for a given time 
    interval, or until a specific `NSDate`.

    It is important to note that this operation does **not** use the `sleep()`
    function, since that is inefficient and blocks the thread on which it is called. 
    Instead, this operation uses `dispatch_after` to know when the appropriate amount 
    of time has passed.

    If the interval is negative, or the `NSDate` is in the past, then this operation
    immediately finishes.
*/
public class DelayOperation: Operation {
    // MARK: Types

    private enum Delay {
        case Interval(NSTimeInterval)
        case Date(NSDate)
    }
    
    // MARK: Properties
    
    private let delay: Delay
    
    // MARK: Initialization
    
    public init(interval: NSTimeInterval) {
        delay = .Interval(interval)
        super.init()
    }
    
    public init(until date: NSDate) {
        delay = .Date(date)
        super.init()
    }
    
    override public func execute() {
        let interval: NSTimeInterval
        
        // Figure out how long we should wait for.
        switch delay {
            case .Interval(let theInterval):
                interval = theInterval

            case .Date(let date):
                interval = date.timeIntervalSinceNow
        }
        
        guard interval > 0 else {
            finish()
            return
        }
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
        dispatch_after(when, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            // If we were cancelled, then finish() has already been called.
            if !self.cancelled {
                self.finish()
            }
        }
    }
}
