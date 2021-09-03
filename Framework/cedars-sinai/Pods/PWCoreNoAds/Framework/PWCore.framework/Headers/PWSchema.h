//
//  PWSchema.h

//
//  Copyright (c) 2013 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `PWSchema` objects are applied to `PWStructure` items and define what fields of data a particular `PWStructure` item can contain. You can modify `PWSchema` values in the MaaS portal. `PWSchema` conforms to the `NSCoding` and `NSCopying` protocol.
*/

@interface PWSchema : NSObject <NSCoding, NSCopying>

/**
 A string that is used to identify the Schema ID.
 */
@property (nonatomic, readonly) NSString *schemaID;

/**
 A string that is used to identify the schema name.
 */
@property (nonatomic, readonly) NSString *name;

/**
 An array of `PWSchemaField` objects associated with the schema.
 */
@property (nonatomic, readonly) NSArray *fields;

/**
 A array of attributes associated with the schema. Attribute objects are of `NSDictionary` type: `@{@"key" : @"value"}`.
 */
@property (nonatomic, readonly) NSArray *attributes;

/**
 A array of tags associated with the schema. A tag is an `NSString` object.
 */
@property (nonatomic, readonly) NSArray *tags;

/**
 The creation date of the schema.
 */
@property (nonatomic, readonly) NSDate *creationDate;

/**
 The date of the last update for the schema.
 */
@property (nonatomic, readonly) NSDate *lastUpdated;

///-----------------------
/// @name Convenience
///-----------------------

/**
 Convenience method to instantiate a `PWSchema` object from a properly formatted `NSDictionary` object.
 @param dictionary The dictionary from which to instantiate the `PWSchema` object.
 */
+ (instancetype)unpack:(NSDictionary *)dictionary;

/**
 Returns an `NSDictionary` representation of the current structure.
 */
- (NSDictionary *)dictionary;


@end
