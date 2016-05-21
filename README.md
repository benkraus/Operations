# Operations

This is a fork of [PSOperations](https://github.com/pluralsight/PSOperations). My intention is to stay very up to date and follow that repo closely. This fork provides the following benefits:
* Carthage compatability - A separate framework target has been created for each platform (iOS, tvOS, watchOS and Mac OS X).
* HealthKit and PassKit extras have been factored out into their own frameworks. This is because importing them without using them could cause app rejections, or marking your app as supporting Wallet when it really does not.
* Licenses in the source files have been cleaned up.

My intention is to also clean up the tests, as well as write extensive documentation for this framework.

For those unfamiliar with PSOperations, PSOperations (and thus this) is an adaptation of the sample code provided in the Advanced NSOperations session of WWDC 2015. It has been updated to work with the latest Swift changes as of Xcode 7. For usage examples, see [WWDC 2015 Advanced NSOperations](https://developer.apple.com/videos/wwdc/2015/?id=226) and/or look at the included unit tests.

This code is different from the WWDC sample code in that it contains fixes and improvements around canceling operations, and negating conditions properly.

A difference from the WWDC Sample code worth mentioning:
* When conditions are evaluated and they fail the associated operation is cancelled. The operation still goes through the same flow otherwise, only now it will be marked as cancelled.
