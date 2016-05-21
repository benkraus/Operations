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

#if !os(OSX)

import Foundation
import CoreLocation

/**
 `LocationOperation` is an `Operation` subclass to do a "one-shot" request to
 get the user's current location, with a desired accuracy. This operation will
 prompt for `WhenInUse` location authorization, if the app does not already
 have it.
 */
public class LocationOperation: Operation, CLLocationManagerDelegate {
    // MARK: Properties
    
    private let accuracy: CLLocationAccuracy
    private var manager: CLLocationManager?
    private let handler: CLLocation -> Void
    
    // MARK: Initialization
    
    public init(accuracy: CLLocationAccuracy, locationHandler: CLLocation -> Void) {
        self.accuracy = accuracy
        self.handler = locationHandler
        super.init()
        #if !os(tvOS)
            addCondition(Capability(Location.WhenInUse))
        #else
            addCondition(Capability(Location()))
        #endif
        addCondition(MutuallyExclusive<CLLocationManager>())
        addObserver(BlockObserver(cancelHandler: { [weak self] _ in
            dispatch_async(dispatch_get_main_queue()) {
                self?.stopLocationUpdates()
            }
        }))
    }
    
    override public func execute() {
        dispatch_async(dispatch_get_main_queue()) {
            /*
            `CLLocationManager` needs to be created on a thread with an active
            run loop, so for simplicity we do this on the main queue.
            */
            let manager = CLLocationManager()
            manager.desiredAccuracy = self.accuracy
            manager.delegate = self
            
            if #available(iOS 9.0, *) {
                manager.requestLocation()
            } else {
                #if !os(tvOS) && !os(watchOS)
                    manager.startUpdatingLocation()
                #endif
            }
            
            self.manager = manager
        }
    }
    
    private func stopLocationUpdates() {
        manager?.stopUpdatingLocation()
        manager = nil
    }
    
    // MARK: CLLocationManagerDelegate
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last where location.horizontalAccuracy <= accuracy {
            stopLocationUpdates()
            handler(location)
            finish()
        }
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        stopLocationUpdates()
        finishWithError(error)
    }
}

#endif
