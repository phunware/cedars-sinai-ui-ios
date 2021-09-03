PWCore SDK for iOS
================

Version 3.8.7

This is Phunware's iOS SDK for the Core module. Visit http://maas.phunware.com/ for more details and to sign up.

Requirements
------------

- iOS 10.0 or greater
- Xcode 8 or greater

Documentation
------------
PWCore documentation is included in the Documents folder in the repository as both HTML and as a .docset. You can also find the latest documentation here: http://phunware.github.io/maas-core-ios-sdk/

Installation
------------

PWCore is a required dependency for all MaaS modules.

It's recommended that you add PWCore.framework to the 'Vendor/Phunware' directory, then add it to your Xcode project.

The following frameworks are required:

````
SystemConfiguration.framework
MobileCoreServices.framework
QuartzCore.framework
CoreTelephony.framework
Security.framework
````

The following frameworks are optional:

````
CoreLocation.framework
UIKit.framework
````
**NOTE**: CoreLocation is used for comprehensive analytics. Apple mandates that your app have a good reason for enabling location services. Apple will deny your app if location is not a core feature for your app.

After specifying the frameworks, you will need to add a linker flag to your build target.

Alternatively, you can install PWCore using CocoaPods:

````
// Add this to your Podfile:
pod PWCore
````

To do this:
1. Navigate to your build target.
2. Navigate to the Build Settings tab.
3. Find the Linking Section -> Other Linker Flags.
4. Add "-ObjC" to Other Linker Flags.

You can now install additional MaaS modules.


Application Setup
-----------------
At the top of your application delegate implementation (.m) file, add the following:

````objective-c
#import <PWCore/PWCore.h>
````

Inside your application delegate, you will need to initialize MaaS Core in the application:didFinishLaunchingWithOptions: method:

````objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// These values can be found for your application in the MaaS portal (http://maas.phunware.com/clients).
    [PWCore setApplicationID:@"APPLICATION_ID"
    		    setAccessKey:@"ACCESS_KEY"
                signatureKey:@"SIGNATURE_KEY"];
    ...
}
````

Location Permissions
--------------------

Location authorization of "When In Use" or "Always" is encouraged when starting PWCore for analytics purposes. Please follow [Apple's Best Practices](https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services) for requesting location permissions.

Attribution
-----------
PWCore uses the following third-party components. All components are prefixed so you won't have to worry about namespace collisions.

<table>
  <tr>
  <th style="text-align:center;">Component</th>
  <th style="text-align:center;">Description</th>
  <th style="text-align:center;">License</th>
  </tr>
  <tr>
    <td><a href="https://github.com/AFNetworking/AFNetworking">AFNetworking</a></td>
    <td>
     A delightful iOS and OS X networking framework.
    </td>
    <td style="text-align:center;""><a href="https://github.com/AFNetworking/AFNetworking/blob/master/LICENSE">MIT</a>
    </td>
  </tr>
  <tr>
    <td><a href="https://github.com/tumblr/TMCache">TMCache</a></td>
    <td>
     Fast parallel object cache for iOS and OS X.
    </td>
    <td style="text-align:center;""><a href="https://github.com/tumblr/TMCache/blob/master/LICENSE.txt">Apache 2.0</a>
    </td>
  </tr>
  <tr>
    <td><a href="https://github.com/ZipArchive/ZipArchive">SSZipArchive</a></td>
    <td>
     Zipping and unzipping files for iOS and OS X.
    </td>
    <td style="text-align:center;""><a href="https://github.com/ZipArchive/ZipArchive/blob/master/LICENSE.txt">MIT</a>
    </td>
  </tr>
</table>

Privacy
-----------
You understand and consent to Phunware’s Privacy Policy located at www.phunware.com/privacy. If your use of Phunware’s software requires a Privacy Policy of your own, you also agree to include the terms of Phunware’s Privacy Policy in your Privacy Policy to your end users.

Terms
-----------
Use of this software requires review and acceptance of our terms and conditions for developer use located at http://www.phunware.com/terms/
