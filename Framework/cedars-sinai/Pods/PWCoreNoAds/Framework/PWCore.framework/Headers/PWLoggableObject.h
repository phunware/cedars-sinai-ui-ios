//
//  PWLoggableObject.h
//  PWCore
//
//  Created on 4/1/15.
//  Copyright (c) 2015 Phunware, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PWLoggableObject <NSObject>

/**
  Returns a representation of the object using Foundation objects, as well as some few other supported types:

  - NSString
 
  - NSNumber
 
  - NSNull
 
  - NSArray
 
  - NSDictionary
 
  - NSDate
 
  - CLLocation
  
  - CLRegion
  
  - CLCircularRegion
 */
- (id)packForLogging;

@end
