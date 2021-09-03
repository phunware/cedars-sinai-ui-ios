//
//  PWContainer.h

//
//  Copyright (c) 2013 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Containers hold a single structure. All values in a `PWContainer` object are immutable on the client. You can modify `PWContainer` values in the MaaS portal. `PWContainer` conforms to the `NSCoding` and `NSCopying` protocol.
*/

@interface PWContainer : NSObject <NSCoding, NSCopying>

/**
 An `NSString` that is used to identify the Container ID.
 */
@property (nonatomic, readonly) NSString *containerID;

/**
 A `NSString` that is used to identify the container name.
 */
@property (nonatomic, readonly) NSString *name;

/**
 A array of tags associated with the container. A tag is an `NSString` object.
 */
@property (nonatomic, readonly) NSArray *tags;

/**
 The creation date of the container.
 */
@property (nonatomic, readonly) NSDate *creationDate;

/**
 The date of the last update for the container.
 */
@property (nonatomic, readonly) NSDate *lastUpdated;

///-----------------------
/// @name Convenience
///-----------------------

/**
 Convenience method to instantiate a `PWContainer` object from a properly formatted `NSDictionary` object.
 @param dictionary The dictionary from which to instantiate the `PWContainer` object.
 */
+ (instancetype)unpack:(NSDictionary *)dictionary;

/**
 Returns an `NSDictionary` representation of the current container.
 */
- (NSDictionary *)dictionary;

@end
