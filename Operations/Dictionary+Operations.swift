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

extension Dictionary {
    /**
        It's not uncommon to want to turn a sequence of values into a dictionary,
        where each value is keyed by some unique identifier. This initializer will
        do that.
        
        - parameter sequence: The sequence to be iterated

        - parameter keyer: The closure that will be executed for each element in 
            the `sequence`. The return value of this closure, if there is one, will
            be used as the key for the value in the `Dictionary`. If the closure 
            returns `nil`, then the value will be omitted from the `Dictionary`.
    */
    init<Sequence: SequenceType where Sequence.Generator.Element == Value>(sequence: Sequence, keyMapper: Value -> Key?) {
        self.init()

        for item in sequence {
            if let key = keyMapper(item) {
                self[key] = item
            }
        }
    }
}
