//
//  PWStructure.h

//
//  Copyright (c) 2013 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PWSchema;

/**
 `PWStructure` items are used to build the structure and hierarchy of the data. Each structure item that is defined as an object can also optionally be assigned a schema that defines what content can be saved to those structure items. All values in a `PWStructure` object are immutable on the client. You can modify `PWStructure` values in the MaaS portal. `PWStructure` conforms to the `NSCoding` and `NSCopying` protocol.
 */

@interface PWStructure : NSObject <NSCoding, NSCopying>

/**
 An integer that is used to identify the Structure ID.
 */
@property (nonatomic, readonly) NSUInteger structureID;

/**
 An integer that is used to identify the Parent ID.
 */
@property (nonatomic, readonly) NSUInteger parentID;

/**
 A string that is used to identify the Container ID.
 */
@property (nonatomic, readonly) NSString *containerID;

/**
 A string that is used to identify the Schema ID.
 */
@property (nonatomic, readonly) NSString *schemaID;

/**
 A string that is used to identify the structure name.
 */
@property (nonatomic, readonly) NSString *name;

/**
 A string that is used to identify the structure type.
 */
@property (nonatomic, readonly) NSString *type;

/**
 A string that is used to identify the structure field.
 */
@property (nonatomic, readonly) NSString *field;

/**
 A string that is used to identify the structure name.
 */
@property (nonatomic, readonly) NSString *structureDescription;

/**
 An unsigned integer that is used to identify the structure name.
 */
@property (nonatomic, readonly) NSUInteger sortOrder;

/**
 An boolean that is used to identify the Parent ID.
 */
@property (nonatomic, readonly) BOOL isActive;

/**
 The creation date of the structure.
 */
@property (nonatomic, readonly) NSDate *creationDate;

/**
 The date of the last update for the structure.
 */
@property (nonatomic, readonly) NSDate *lastUpdated;

/**
 The `PWSchema` object associated with the current structure, if one exists.
 */
@property (nonatomic, readonly) PWSchema *schema;

/**
 The content, where the structure is based on the associated `PWSchema`.
 */
@property (nonatomic, readonly) NSDictionary *content;

/**
 Depending on the API method, the child `PWStructure` items may be return as well.
*/
@property (nonatomic, readonly) NSArray *children;

///-----------------------
/// @name Convenience
///-----------------------

/** 
 Convenience method to instantiate a `PWStructure` object from a properly formatted `NSDictionary` object.
 @param dictionary The dictionary from which to instantiate the `PWStructure` object.
*/
+ (instancetype)unpack:(NSDictionary *)dictionary;

/**
 Returns an `NSDictionary` representation of the current structure.
 */
- (NSDictionary *)dictionary;

@end
