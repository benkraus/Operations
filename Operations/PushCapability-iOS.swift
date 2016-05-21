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

#if os(iOS)

import UIKit
    
public struct Push: CapabilityType {
    
    public static func didReceiveToken(token: NSData) {
        authorizer.completeAuthorization(token, error: nil)
    }
    
    public static func didFailRegistration(error: NSError) {
        authorizer.completeAuthorization(nil, error: error)
    }

    public static let name = "Push"
    
    public init(application: UIApplication) {
        if authorizer.application == nil {
            authorizer.application = application
        }
    }
    
    public func requestStatus(completion: CapabilityStatus -> Void) {
        if let _ = authorizer.token {
            completion(.Authorized)
        } else {
            completion(.NotDetermined)
        }
    }
    
    public func authorize(completion: CapabilityStatus -> Void) {
        authorizer.authorize(completion)
    }
    
}

private let authorizer = PushAuthorizer()
    
private class PushAuthorizer {
    
    var application: UIApplication?
    var token: NSData?
    var completion: (CapabilityStatus -> Void)?
    
    func authorize(completion: CapabilityStatus -> Void) {
        guard self.completion == nil else {
            fatalError("Cannot request push authorization while a request is already in progress")
        }
        
        self.completion = completion
        
        guard let application = application else {
            fatalError("An application has not yet been configured, so this won't work")
        }
        
        application.registerForRemoteNotifications()
    }
    
    private func completeAuthorization(token: NSData?, error: NSError?) {
        self.token = token
        
        guard let completion = self.completion else { return }
        self.completion = nil
        
        if let _ = self.token {
            completion(.Authorized)
        } else if let error = error {
            completion(.Error(error))
        } else {
            completion(.NotDetermined)
        }
    }
    
}

#endif
