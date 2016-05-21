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

// Leaving out this conditional compilation because it is excluded from targets
// that don't support this code, and I was hitting a build error with it,
// similar to: https://openradar.appspot.com/23487944

//#if os(tvOS)

import Foundation
import CoreLocation

public struct Location: CapabilityType {
    public static let name = "Location"

    public init() { }

    public func requestStatus(completion: CapabilityStatus -> Void) {
        guard CLLocationManager.locationServicesEnabled() else {
            completion(.NotAvailable)
            return
        }
        
        let actual = CLLocationManager.authorizationStatus()
        
        switch actual {
            case .NotDetermined: completion(.NotDetermined)
            case .Restricted: completion(.NotAvailable)
            case .Denied: completion(.Denied)
            case .AuthorizedWhenInUse: completion(.Authorized)
            case .AuthorizedAlways:
                fatalError(".Always should be unavailable on tvOS")
        }
    }
    
    public func authorize(completion: CapabilityStatus -> Void) {
        Authorizer.authorize(completion)
    }
}

private let Authorizer = LocationAuthorizer()

private class LocationAuthorizer: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    private var completion: (CapabilityStatus -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func authorize(completion: CapabilityStatus -> Void) {
        guard self.completion == nil else {
            fatalError("Attempting to authorize location when a request is already in-flight")
        }
        self.completion = completion
        
        let key = "NSLocationWhenInUseUsageDescription"
        manager.requestWhenInUseAuthorization()
        
        // This is helpful when developing an app.
        assert(NSBundle.mainBundle().objectForInfoDictionaryKey(key) != nil, "Requesting location permission requires the \(key) key in your Info.plist")
    }
    
    @objc func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if let completion = self.completion where manager == self.manager && status != .NotDetermined {
            self.completion = nil
            
            switch status {
                case .AuthorizedWhenInUse:
                    completion(.Authorized)
                case .Denied:
                    completion(.Denied)
                case .Restricted:
                    completion(.NotAvailable)
                case .AuthorizedAlways:
                    fatalError(".Always should be unavailable on tvOS")
                case .NotDetermined:
                    fatalError("Unreachable due to the if statement, but included to keep clang happy")
            }
        }
    }
    
}

//#endif
