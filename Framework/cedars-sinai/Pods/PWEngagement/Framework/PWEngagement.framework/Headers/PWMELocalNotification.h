//
//  PWMELocalNotification.h
//  PWEngagement
//
//  Copyright (c) 2015 Phunware, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PWEngagement/PWMEZoneMessage.h>

extern NSString *const PWMELocalNotificationSendNotification;

// UserInfo dictionary keys
extern NSString *const PWMELocalNotificationUserInfoMessageIdentifierKey;
extern NSString *const PWMELocalNotificationUserInfoCampaignTypeKey;
extern NSString *const PWMELocalNotificationUserInfoAlertTitleKey;
extern NSString *const PWMELocalNotificationUserInfoAlertBodyKey;

/**
 * A PWMELocalNotification object holds the information related to a local notification that will be shown to the user. The PWMELocalNotification object allows the alert title and alert body to be modified if needed.
 */
@interface PWMELocalNotification : NSObject

/**
 Returns the title of the local notification.
 @discussion This method should never return `nil`.
 @return The title of this local notification.
 */
@property (copy) NSString *alertTitle;

/**
 Returns the alert body of the local notification.
 @discussion This method should never return `nil`.
 @return The message of this local notification.
 */
@property (copy) NSString *alertBody;

/**
 The zone message associated with the local notification.
 @return The zone message associated with the local notification.
 */
@property (readonly) PWMEZoneMessage *message;

@end
