//
//  PWSchemaField.h

//
//  Copyright (c) 2013 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `PWSchemaField` objects define the fields that are specified for a `PWSchema` object. A `PWSchemaField` object has a few base parameters and can be extended to support additional key:value pairs. Additional key:value pairs are available in the `customKeys` property. You can modify `PWSchemaField` values in the MaaS portal. `PWSchemaField` conforms to the `NSCoding` and `NSCopying` protocol.
*/

@interface PWSchemaField : NSObject <NSCoding, NSCopying>

/**
 A string describing the field key.
 */
@property (nonatomic, readonly) NSString *field;

/**
 A string describing the field label.
 */
@property (nonatomic, readonly) NSString *label;

/**
 A string describing the field type.
 */
@property (nonatomic, readonly) NSString *type;

/**
 A boolean value which indicates whether or note this field is required.
 */
@property (nonatomic, readonly) BOOL required;

/**
 A string describing the field.
 */
@property (nonatomic, readonly) NSString *fieldDescription;

/**
 Additional keys are based on the type and can be modified in the MaaS portal.
 */
@property (nonatomic, readonly) NSDictionary *customKeys;

///-----------------------
/// @name Convenience
///-----------------------

/**
 Convenience method to instantiate a `PWSchemaField` object from a properly formatted `NSDictionary` object.
 @param dictionary The dictionary from which to instantiate the `PWSchemaField` object.
 */
+ (instancetype)unpack:(NSDictionary *)dictionary;

/**
 Returns an `NSDictionary` representation of the current container.
 */
- (NSDictionary *)dictionary;

@end
