//
//  PWMEAttributeManager.h
//  PWEngagement
//
//  Copyright (c) 2015 Phunware, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A block that will be called after the attributes are updated in the server.
 *
 * - *error* If the update completed successfully, this parameter is `nil`; otherwise, this parameter holds an error object that describes the error.
 */
typedef void (^PWUpdateAttributesBlock)(NSError *error);
/**
 * A block that will be called after the attribute metadata is fetched from the server.
 *
 * - *attributes* The attributes with their metadata.
 * - *error* If the fetch completed successfully, this parameter is `nil`; otherwise, this parameter holds an error object that describes the error.
 */
typedef void (^PWFetchAttributeMetadataBlock)(NSArray *attributes, NSError *error);
/**
 * A block that will be called after the attributes are fetched from the server.
 *
 * - *attributes* The attributes associated with the device.
 * - *error* If the fetch completed successfully, this parameter is `nil`; otherwise, this parameter holds an error object that describes the error.
 */
typedef void (^PWFetchAttributesBlock)(NSDictionary *attributes, NSError *error);
/**
 * A block that will be called after the custom identifier is fetched from the server.
 *
 * - *identifer* User identifier.
 * - *error* If the fetch completed successfully, this parameter is `nil`; otherwise, this parameter holds an error object that describes the error.
 */
typedef void (^PWFetchCustomIdentifierBlock)(NSString *identifier, NSError *error);

/**
 The `PWMEAttributeManager` class is the central point for fetching and updating attributes associated with the device or user. You use an instance of this class to fetch and update profile and user attributes.
 */

@interface PWMEAttributeManager : NSObject

/**
 Returns the shared instance of the `PWMEAttributeManager` class.
 @return The shared instance of the `PWMEAttributeManager` class.
 */
+ (instancetype)sharedManager;

/**
 Retrieves all profile attribute Metadata.
 @param completion A block that will be executed when the fetch is complete.
 */
- (void)fetchProfileAttributeMetadataWithCompletion:(PWFetchAttributeMetadataBlock)completion;

/**
 Retrieves all profile attributes associated with this device.
 @param completion A block that will be executed after the fetch is compete.
 */
- (void)fetchProfileAttributesWithCompletion:(PWFetchAttributesBlock)completion;

/**
 Update profile attributes to be associated with the device.
 @param attributes The attributes that you would like to associate with the device. 
 @param completion A block that will be executed after the update is complete.
 @discussion All attributes that you wish to be associated with this device must be in the `attributes` dictionary. Any items omitted will be removed.
 */
- (void)updateProfileAttributes:(NSDictionary *)attributes completion:(PWUpdateAttributesBlock)completion;


@end

