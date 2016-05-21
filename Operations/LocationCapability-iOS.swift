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
import CoreLocation

public enum Location: CapabilityType {
    public static let name = "Location"
    
    case WhenInUse
    case Always
    
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
            case .AuthorizedAlways: completion(.Authorized)
            case .AuthorizedWhenInUse:
                if self == .WhenInUse {
                    completion(.Authorized)
                } else {
                    // the user wants .Always, but has .WhenInUse
                    // return .NotDetermined so that we can prompt to upgrade the permission
                    completion(.NotDetermined)
                }
        }
    }
    
    public func authorize(completion: CapabilityStatus -> Void) {
        Authorizer.authorize(self, completion: completion)
    }
}
    
private let Authorizer = LocationAuthorizer()
    
private class LocationAuthorizer: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    private var completion: (CapabilityStatus -> Void)?
    private var kind = Location.WhenInUse
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func authorize(kind: Location, completion: CapabilityStatus -> Void) {
        guard self.completion == nil else {
            fatalError("Attempting to authorize location when a request is already in-flight")
        }
        self.completion = completion
        self.kind = kind
        
        let key: String
        switch kind {
            case .WhenInUse:
                key = "NSLocationWhenInUseUsageDescription"
                manager.requestWhenInUseAuthorization()
                
            case .Always:
                key = "NSLocationAlwaysUsageDescription"
                manager.requestAlwaysAuthorization()
        }
        
        // This is helpful when developing an app.
        assert(NSBundle.mainBundle().objectForInfoDictionaryKey(key) != nil, "Requesting location permission requires the \(key) key in your Info.plist")
    }
    
    @objc func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if let completion = self.completion where manager == self.manager && status != .NotDetermined {
            self.completion = nil
            
            switch status {
                case .AuthorizedAlways:
                    completion(.Authorized)
                case .AuthorizedWhenInUse:
                    completion(kind == .WhenInUse ? .Authorized : .Denied)
                case .Denied:
                    completion(.Denied)
                case .Restricted:
                    completion(.NotAvailable)
                case .NotDetermined:
                    fatalError("Unreachable due to the if statement, but included to keep clang happy")
            }
        }
    }
    
}

#endif
