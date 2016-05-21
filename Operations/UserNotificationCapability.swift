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
    
public struct UserNotification: CapabilityType {
    
    public static let name = "UserNotificaton"
    
    public static func didRegisterUserSettings() {
        authorizer.completeAuthorization()
    }
    
    public enum Behavior {
        case Replace
        case Merge
    }
    
    private let settings: UIUserNotificationSettings
    private let behavior: Behavior
    
    public init(settings: UIUserNotificationSettings, behavior: Behavior = .Merge, application: UIApplication) {
        self.settings = settings
        self.behavior = behavior
        
        if authorizer._application == nil {
            authorizer.application = application
        }
    }
    
    public func requestStatus(completion: CapabilityStatus -> Void) {
        let registered = authorizer.areSettingsRegistered(settings)
        completion(registered ? .Authorized : .NotDetermined)
    }
    
    public func authorize(completion: CapabilityStatus -> Void) {
        let settings: UIUserNotificationSettings
        
        switch behavior {
            case .Replace:
                settings = self.settings
            case .Merge:
                let current = authorizer.application.currentUserNotificationSettings()
                settings = current?.settingsByMerging(self.settings) ?? self.settings
        }
        
        authorizer.authorize(settings, completion: completion)
    }
    
}
    
private let authorizer = UserNotificationAuthorizer()
    
private class UserNotificationAuthorizer {
    
    var _application: UIApplication?
    var application: UIApplication {
        set {
            _application = newValue
        }
        get {
            guard let application = _application else {
                fatalError("Application not yet configured. Results would be undefined.")
            }
            
            return application
        }
    }
    var completion: (CapabilityStatus -> Void)?
    var settings: UIUserNotificationSettings?
    
    func areSettingsRegistered(settings: UIUserNotificationSettings) -> Bool {
        let current = application.currentUserNotificationSettings()
        
        return current?.contains(settings) ?? false
    }
    
    func authorize(settings: UIUserNotificationSettings, completion: CapabilityStatus -> Void) {
        guard self.completion == nil else {
            fatalError("Cannot request push authorization while a request is already in progress")
        }
        guard self.settings == nil else {
            fatalError("Cannot request push authorization while a request is already in progress")
        }
        
        self.completion = completion
        self.settings = settings
        
        application.registerUserNotificationSettings(settings)
    }
    
    private func completeAuthorization() {
        
        guard let completion = self.completion else { return }
        guard let settings = self.settings else { return }
        
        self.completion = nil
        self.settings = nil
        
        let registered = areSettingsRegistered(settings)
        completion(registered ? .Authorized : .Denied)
    }
    
}

#endif
