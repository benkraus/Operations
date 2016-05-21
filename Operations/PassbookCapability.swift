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

import Foundation
import PassKit
import Operations

public enum Passbook: CapabilityType {
    public static let name = "Passbook"
    
    case ViewPasses
    case AddPasses
    
    public func requestStatus(completion: CapabilityStatus -> Void) {
        switch self {
            case .ViewPasses:
                if PKPassLibrary.isPassLibraryAvailable() {
                    completion(.Authorized)
                } else {
                    completion(.NotAvailable)
                }
            case .AddPasses:
                if PKAddPassesViewController.canAddPasses() {
                    completion(.Authorized)
                } else {
                    completion(.NotAvailable)
                }
        }
    }
    
    public func authorize(completion: CapabilityStatus -> Void) {
        // Since requestStatus() never returns .NotDetermined, this method should never be called
        fatalError("This should never be invoked")
    }
}

#endif
