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

#if !os(watchOS)

import Foundation
import SystemConfiguration

/**
    This is a condition that performs a very high-level reachability check.
    It does *not* perform a long-running reachability check, nor does it respond to changes in reachability.
    Reachability is evaluated once when the operation to which this is attached is asked about its readiness.
*/
public struct ReachabilityCondition: OperationCondition {
    public static let hostKey = "Host"
    public static let name = "Reachability"
    public static let isMutuallyExclusive = false
    
    let host: NSURL
    
    
    public init(host: NSURL) {
        self.host = host
    }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        ReachabilityController.requestReachability(host) { reachable in
            if reachable {
                completion(.Satisfied)
            }
            else {
                let error = NSError(code: .ConditionFailed, userInfo: [
                    OperationConditionKey: self.dynamicType.name,
                    self.dynamicType.hostKey: self.host
                ])
                
                completion(.Failed(error))
            }
        }
    }
    
}

/// A private singleton that maintains a basic cache of `SCNetworkReachability` objects.
private class ReachabilityController {
    static var reachabilityRefs = [String: SCNetworkReachability]()

    static let reachabilityQueue = dispatch_queue_create("Operations.Reachability", DISPATCH_QUEUE_SERIAL)
    
    static func requestReachability(url: NSURL, completionHandler: (Bool) -> Void) {
        if let host = url.host {
            dispatch_async(reachabilityQueue) {
                var ref = self.reachabilityRefs[host]
                
                if ref == nil {
                    let hostString = host as NSString
                    ref = SCNetworkReachabilityCreateWithName(nil, hostString.UTF8String)
                }
                
                if let ref = ref {
                    self.reachabilityRefs[host] = ref
                    
                    var reachable = false
                    var flags: SCNetworkReachabilityFlags = []
                    if SCNetworkReachabilityGetFlags(ref, &flags) {
                        /*
                        Note that this is a very basic "is reachable" check.
                        Your app may choose to allow for other considerations,
                        such as whether or not the connection would require
                        VPN, a cellular connection, etc.
                        */
                        reachable = flags.contains(.Reachable)
                    }
                    completionHandler(reachable)
                }
                else {
                    completionHandler(false)
                }
            }
        }
        else {
            completionHandler(false)
        }
    }
}

#endif
