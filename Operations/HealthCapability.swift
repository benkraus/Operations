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

#if os(iOS) || os(watchOS)

import Foundation
import HealthKit
import Operations

public struct Health: CapabilityType {
    public static let name = "Health"
    
    private let readTypes: Set<HKSampleType>
    private let writeTypes: Set<HKSampleType>
    
    public init(typesToRead: Set<HKSampleType>, typesToWrite: Set<HKSampleType>) {
        self.readTypes = typesToRead
        self.writeTypes = typesToWrite
    }
    
    public func requestStatus(completion: CapabilityStatus -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(.NotAvailable)
            return
        }
        
        let notDeterminedTypes = writeTypes.filter { SharedHealthStore.authorizationStatusForType($0) == .NotDetermined }
        if notDeterminedTypes.isEmpty == false {
            completion(.NotDetermined)
            return
        }
        
        let deniedTypes = writeTypes.filter { SharedHealthStore.authorizationStatusForType($0) == .SharingDenied }
        if deniedTypes.isEmpty == false {
            completion(.Denied)
            return
        }
        
        // if we get here, then every write type has been authorized
        // there's no way to know if we have read permissions,
        // so the best we can do is see if we've ever asked for authorization
        
        let unrequestedReadTypes = readTypes.subtract(requestedReadTypes)
        
        if unrequestedReadTypes.isEmpty == false {
            completion(.NotDetermined)
            return
        }
        
        // if we get here, then there was nothing to request for reading or writing
        // thus, everything is authorized
        completion(.Authorized)
    }
    
    public func authorize(completion: CapabilityStatus -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(.NotAvailable)
            return
        }
        
        // make a note that we've requested these types before
        requestedReadTypes.unionInPlace(readTypes)
        
        // This method is smart enough to not re-prompt for access if it has already been granted.
        SharedHealthStore.requestAuthorizationToShareTypes(writeTypes, readTypes: readTypes) { _, error in
            if let error = error {
                completion(.Error(error))
            } else {
                self.requestStatus(completion)
            }
        }
    }
    
}

/**
    HealthKit does not report on whether or not you're allowed to read certain data types.
    Instead, we'll keep track of which types we've already request to read. If a new request
    comes along for a type that's not in here, we know that we'll need to re-prompt for
    permission to read that particular type.
*/
private var requestedReadTypes = Set<HKSampleType>()
private let SharedHealthStore = HKHealthStore()

#endif
