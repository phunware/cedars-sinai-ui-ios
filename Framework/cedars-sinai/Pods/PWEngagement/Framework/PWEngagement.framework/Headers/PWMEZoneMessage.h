//
//  PWMEMessage.h
//  PWEngagement
//
//  Copyright (c) 2015 Phunware, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Campaign type string value for geofence entry campaigns.
 */
static NSString *const PWMEZoneMessageGeofenceEntryCampaignType   = @"GEOFENCE_ENTRY";
/**
 * Campaign type string value for geofence exit campaigns.
 */
static NSString *const PWMEZoneMessageGeofenceExitCampaignType    = @"GEOFENCE_EXIT";
/**
 * Campaign type string value for broadcast campaigns.
 */
static NSString *const PWMEZoneMessageBroadCastCampaignType         = @"BROADCAST";
/**
 * Campaign type string value for on-demond broadcast campaigns.
 */
static NSString *const PWMEZoneMessageOnDemandBroadCastCampaignType = @"ON_DEMAND_BROADCAST";



/**
 A `PWZoneMessage` is a communication (generally marketing-related) sent from the server.
 */
@interface PWMEZoneMessage : NSObject <NSSecureCoding, NSCopying>


/**
 Returns the alert title of this message.
 @return The alert title of this message.
 */
@property (readonly, nonnull) NSString *alertTitle;


/**
 Returns the alert body of this message.
 @return The alert body of this message.
 */
@property (readonly, nonnull) NSString *alertBody;


/**
 Returns the promotion title of this message.
 @return The promotion title of this message.
 */
@property (readonly, nullable) NSString *promotionTitle;


/**
 Returns the promotion body of this message. The value returned by this method is usually HTML.
 @discussion  To mark this message as read, pass this message to the `PWMEZoneMessageManager` `readMessage:` method.
 @return The body of this message.
 */
@property (readonly, nullable) NSString *promotionBody;


/**
 Returns the metadata associated with the message.
 @return Returns the metadata of this message.
 */
@property (readonly, nonnull) NSDictionary <NSString *, id> *metaData;

/**
 Returns the internal unique identifier of the message. This identifier also idenfities the campaign this message was sent for.
 @discussion There can be at most one message associated with a campaign at any given time.
 @return The internal unique identifier message.
 */
@property (readonly, nullable) NSString *identifier;

/**
 A Boolean value indicating whether or not the entry is read.
 @discussion A message is only considered read if it has been marked as such by the application. To mark this message as read, pass this message to the `PWMEZoneMessageManager` `readMessage:` method.
 @return A Boolean value indicating whether or not the message has been read.
 */
@property (readonly) BOOL isRead;

/**
 A string containing the campaign type of the message.
 @return A string containing the campaign type of the message.
 */
@property (readonly, nonnull) NSString *campaignType;

/**
 Returns the timestamp identifying when the message is saved.
 @return the timestamp identifying when the message is saved.
 */
@property (readonly, nullable) NSDate *timestamp;

/**
 Deletes this message.
 */
- (void)remove;

/**
 Marks this message as read.
 */
- (void)read;

@end
