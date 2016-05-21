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
import CloudKit

public struct iCloudContainer: CapabilityType {
    
    public static let name = "iCloudContainer"
    
    private let container: CKContainer
    private let permissions: CKApplicationPermissions
    
    public init(container: CKContainer, permissions: CKApplicationPermissions = []) {
        self.container = container
        self.permissions = permissions
    }
    
    public func requestStatus(completion: CapabilityStatus -> Void) {
        verifyAccountStatus(container, permission: permissions, shouldRequest: false, completion: completion)
    }
    
    public func authorize(completion: CapabilityStatus -> Void) {
        verifyAccountStatus(container, permission: permissions, shouldRequest: true, completion: completion)
    }
    
}

private func verifyAccountStatus(container: CKContainer, permission: CKApplicationPermissions, shouldRequest: Bool, completion: CapabilityStatus -> Void) {
    container.accountStatusWithCompletionHandler { accountStatus, accountError in
        switch accountStatus {
            case .NoAccount: completion(.NotAvailable)
            case .Restricted: completion(.NotAvailable)
            case .CouldNotDetermine:
                let error = accountError ?? NSError(domain: CKErrorDomain, code: CKErrorCode.NotAuthenticated.rawValue, userInfo: nil)
                completion(.Error(error))
            case .Available:
                if permission != [] {
                    verifyPermission(container, permission: permission, shouldRequest: shouldRequest, completion: completion)
                } else {
                    completion(.Authorized)
                }
        }
    }
}

private func verifyPermission(container: CKContainer, permission: CKApplicationPermissions, shouldRequest: Bool, completion: CapabilityStatus -> Void) {
    container.statusForApplicationPermission(permission) { permissionStatus, permissionError in
        switch permissionStatus {
            case .InitialState:
                if shouldRequest {
                    requestPermission(container, permission: permission, completion: completion)
                } else {
                    completion(.NotDetermined)
                }
            case .Denied: completion(.Denied)
            case .Granted: completion(.Authorized)
            case .CouldNotComplete:
                let error = permissionError ?? NSError(domain: CKErrorDomain, code: CKErrorCode.PermissionFailure.rawValue, userInfo: nil)
                completion(.Error(error))
        }
    }
}

private func requestPermission(container: CKContainer, permission: CKApplicationPermissions, completion: CapabilityStatus -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        container.requestApplicationPermission(permission) { requestStatus, requestError in
            switch requestStatus {
                case .InitialState: completion(.NotDetermined)
                case .Denied: completion(.Denied)
                case .Granted: completion(.Authorized)
                case .CouldNotComplete:
                    let error = requestError ?? NSError(domain: CKErrorDomain, code: CKErrorCode.PermissionFailure.rawValue, userInfo: nil)
                    completion(.Error(error))
            }
        }
    }
}

#endif
