//
//  PWEngagement.h
//  PWEngagement
//
//  Created by Xiangwei Wang on 1/29/16.
//  Copyright © 2016 Phunware Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

#import <PWEngagement/PWMEGeozone.h>
#import <PWEngagement/PWMEZoneMessage.h>
#import <PWEngagement/PWMELocalNotification.h>
#import <PWEngagement/PWMEAttributeManager.h>

static NSString *const PWEngagementVersion = @"3.7.4";

/**
 The message identifier key which may be included in the notification's userInfo dictionary.
 */
extern NSString *const PWMEMessageIdentifierKey;

/**
 Post when there was new message arrived, and the identifer of the new message is included in the notification's userInfo dictionary. The message is included in the notification's userInfo dictionary with the `PWMEMessageIdentifierKey` key.
 */
extern NSString *const PWMEReceiveMessageNotificationKey;

/**
 Post when there was a message removed, and the identifer of the removed message is included in the notification's userInfo dictionary. The message is included in the notification's userInfo dictionary with the `PWMEMessageIdentifierKey` key.
 */
extern NSString *const PWMEDeleteMessageNotificationKey;

/**
 Post when there was a message modified, and the identifer of the modified message is included in the notification's userInfo dictionary. The message is included in the notification's userInfo dictionary with the `PWMEMessageIdentifierKey` key.
 */
extern NSString *const PWMEModifyMessageNotificationKey;

/**
 Post when there was a message read, and the identifer of the read message is included in the notification's userInfo dictionary. The message is included in the notification's userInfo dictionary with the `PWMEMessageIdentifierKey` key.
 */
extern NSString *const PWMEReadMessageNotificationKey;

/**
 The error key which may be included in the notification's userInfo dictionary.
 */
extern NSString *const PWMENotificationErrorKey;

/**
 The geo zone identifier key which may be included in the notification's userInfo dictionary.
 */
extern NSString *const PWMEGeoZoneIdentifierKey;

/**
 The geo zone identifier array key which may be included in the notification's userInfo dictionary.
 */
extern NSString *const PWMEGeoZoneIdentifierArrayKey;

/**
 * Posted when determines that the device enters a geo zone. The zone identifer is included in the notification's userInfo dictionary with the `PWMEGeoZoneIdentifierKey` key.
 */
extern NSString *const PWMEEnterGeoZoneNotificationKey;

/**
 * Posted when the zone manager determines that the device exits a geo zone. The zone identifer is included in the notification's userInfo dictionary with the `PWMEGeoZoneIdentifierKey` key.
 */
extern NSString *const PWMEExitGeoZoneNotificationKey;

/**
 * Posted when new zones are added to the zone manager's list of available geo zones. The identifers of the new zones are included in the notification's userInfo dictionary with the 'PWMEGeoZoneIdentifierArrayKey' key.
 */
extern NSString *const PWMEAddGeoZonesNotificationKey;

/**
 * Posted when zones are removed from the zone manager's list of available geo zones. The identifers of the removed zones are included in the notification's userInfo dictionary with the 'PWMEGeoZoneIdentifierArrayKey' key.
 */
extern NSString *const PWMEDeleteGeoZonesNotificationKey;

/**
 * Posted when the information about one or more geo zones is modified. The identifers of the modified zones are included in the notification's userInfo dictionary with the 'PWMEGeoZoneIdentifierArrayKey' key.
 */
extern NSString *const PWMEModifyGeoZonesNotificationKey;

/**
 * Posted when mobile engagement service is ready.
 */
extern NSString *const PWMELocationServiceReadyNotificationKey;

/**
 * Posted when determines that the monitored geo zone changes. 
 */
extern NSString *const PWMEMonitoredGeoZoneChangesNotificationKey;

/**
 * The mobile engagement framework is a location and notification based system.
 *
 * The recommended way to start mobile engagement in your application is to place a call
 * to `+startWithmaasAppId:accessKey:signatureKey:encryptionKey:completion:` in your `-application:didFinishLaunchingWithOptions:` method.
 *
 * This delay defaults to 1 second in order to generally give the application time to
 * fully finish launching.
 *
 * The framework needs you to forward the following methods from your application delegate:
 *
 * - 'didFinishLaunchingWithOptions:withCompletionHandler:'
 * - 'didRegisterForRemoteNotificationsWithDeviceToken:withNotificationHandler:'
 * - 'didFailToRegisterForRemoteNotificationsWithError:withNotificationHandler:'
 * - 'didReceiveRemoteNotification:withNotificationHandler:'
 *
 * You can optionally add a delegate to be informed about errors while initalizing the mobile engagement service and to control the display of local notifications to the user.
 **/
@interface PWEngagement : NSObject

/**
 * Starts the mobile engagement service with environment.
 * @param maasAppId You can find your Application ID in the MaaS portal.
 * @param accessKey A unique key that identifies the client making the request. You can find your Access Key in the MaaS portal.
 * @param signatureKey A unique key that is used to sign requests. The signature is used to both check request authorization as well as data integrity. You can find your Signature Key in the MaaS portal.
 * @param completion A block that notify mobile engagement service is successfully started or failed to start with reason.
 *      - *param1* error It's nil when it's started successfully, or an error object containing information about a problem that indicates mobile engagement service failed to start.
 */
+ (void)startWithMaasAppId:(NSString *)maasAppId
				 accessKey:(NSString *)accessKey
			  signatureKey:(NSString *)signatureKey
				completion:(void(^)(NSError *error))completion;

/**
 * Stop mobile engagement service.
 * @param completion A block that notify mobile engagement service is successfully stopped or failed to stop with reason.
 *
 *      - *error* It's nil when it's stopped successfully, or an error object containing information about a problem that indicates mobile engagement service failed to stop.
 */
+ (void)stopWithCompletion:(void(^)(NSError *error))completion;

/**
 * All the available `PWMEGeozone` list.
 */
+ (NSArray<PWMEGeozone *> *)geozones;

/**
 * All the available `PWMEZoneMessage` list.
 */
+ (NSArray<PWMEZoneMessage *> *)messages;

/**
 * Return the device identifier which the mobile engagement service uses.
 */
+ (NSString *)deviceId;

/**
 * Return the current SDK version of mobile engagement.
 */
+ (NSString *)version;

/**
 * The name of the mobile engagement service.
 */
+ (NSString *)serviceName;

/**
 * Set the block to handle the error when it occurs.
 *
 * @param handler A block that caused mobile engagement service failed.
 *
 *      - *error* An error object containing information about a problem that indicates mobile engagement service failed if the results are retrieved successfully.
 */
+ (void)setErrorHandler:(void(^)(NSError *error))handler;

/**
 * Set the block to handle the local notification which is about to display.
 * @discussion The local notification will be displayed if the block returns `YES`, otherwise, it will not be displayed.
 * @param handler A block that notifies the local notification is about to display, you can control the local notification display and customize the display content.
 *
 *      - *notification* The `PWMELocalNotification` object which contains notification information to display.
 */
+ (void)setLocalNotificationHandler:(BOOL(^)(PWMELocalNotification *notification))handler;

/**
 * Lets the mobile engagement service know that launch process is almost done and the app is almost ready to run.(APNs).
 * @discussion The message deep linking could be fired from the `completionHandler` block. And if returns `YES` in the block, it will prompt an alert tells user how to enable push notification setting when it's disabled, and the prompted message could be configured in localized string file with key `RemindOfEnablePushNotificationSettings`.
 * @param launchOptions A dictionary indicating the reason the app was launched (if any). The contents of this dictionary may be empty in situations where the user launched the app directly. For information about the possible keys in this dictionary and how to handle them, see Launch Options Keys.
 * @param completionHandler A block that tells if user opens the app by tapping a notification.
 *
 *      - *notification* The notification object if user open the app by tapping a notification from notification tray, otherwise, it's nil.
 */
+ (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions withCompletionHandler:(BOOL(^)(PWMELocalNotification *notification))completionHandler;

/**
 * Lets the mobile engagement service know that the app successfully registered with Apple Push Notification service (APNs).
 * @param deviceToken A token that identifies the device to APNs. The token is an opaque data type because that is the form that the provider needs to submit to the APNs servers when it sends a notification to a device. The APNs servers require a binary format for performance reasons. The size of a device token is 32 bytes. Note that the device token is different from the uniqueIdentifier property of UIDevice because, for security and privacy reasons, it must change when the device is wiped.
 */
+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 * Lets the mobile engagement service know that the Apple Push Notification service cannot successfully complete the registration process.
 * @param error An NSError object that encapsulates information why registration did not succeed. The app can choose to display this information to the user.
 */
+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 * Lets the mobile engagement service know that the app receives a local notification, so that it can process it internally.
 * @discussion The message deep linking could be fired from the `completion` block. This method is deprecated since iOS 10, please use `didReceiveNotification:withNotificationHandler:` instead.
 * @param notification A `UILocalNotification` object.
 * @param notificationHandler A block that tells the notification with message which was received.
 *      - *notification* The notification object which was received.
 */
+ (void)didReceiveLocalNotification:(UILocalNotification *)notification withNotificationHandler:(void(^)(PWMELocalNotification *notification))notificationHandler __deprecated;

/**
 * Lets the mobile engagement service know that the app receives a remote notification, so that it can process it internally.
 * @discussion The message deep linking could be fired from the `notificationHandler` block. This method is deprecated since iOS 10, please use `didReceiveNotification:withNotificationHandler:` instead.
 * @param userInfo A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an NSDictionary object; the dictionary may contain only property-list objects plus NSNull.
 * @param notificationHandler A block that tells the notification with message which was received.
 *
 *      - *notification* The notification object which was received.
 */
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo withNotificationHandler:(void(^)(PWMELocalNotification *notification))notificationHandler __deprecated;

/**
 * Lets the mobile engagement service know that the app receives a remote notification, so that it can process it internally.
 * @discussion The message deep linking could be fired from the `notificationHandler` block. This method is deprecated since iOS 10, please use `didReceiveNotification:withNotificationHandler:` instead.
 * @param userInfo A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an NSDictionary object; the dictionary may contain only property-list objects plus NSNull. 
 * @param completionHandler The block to execute when the download operation is complete. When calling this block, pass in the fetch result value that best describes the results of your download operation. You must call this handler and should do so as soon as possible. For a list of possible values, see the UIBackgroundFetchResult type.
 *
 *      - *userInfo* A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an NSDictionary object; the dictionary may contain only property-list objects plus NSNull.
 * @param notificationHandler A block that tells the notification with message which was received.
 *
 *      - *notification*: The notification object which was received.
 */
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler withNotificationHandler:(void(^)(PWMELocalNotification *notification))notificationHandler __deprecated;

/**
 * Lets the mobile engagement service know that the app receives a notification, so that it can process it internally, typically when you receive a notification in `application:didReceiveRemoteNotification:fetchCompletionHandler:`, `userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:` and `userNotificationCenter:willPresentNotification:withCompletionHandler:`.
 * @param userInfo A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an NSDictionary object; the dictionary may contain only property-list objects plus NSNull.
 * @param completion A block that returns the notification with the received message or error.
 * @discussion The message deep linking could be fired from the `notificationHandler` block.
 */
+ (void)didReceiveNotification:(NSDictionary *)userInfo withCompletion:(void(^)(PWMEZoneMessage *message, NSError *error))completion;

/**
 * Set the static identifier to be registered with the current device.
 * @discussion This registers the selected static identifier with the device identifier.
 * @param staticIdentifier The identifier that will be associated with the current device identifier.
 * @param completion The block that notifies the user when static identifier registration is complete, and whether or not there was an error on the registration request.
 */
+ (void)setStaticIdentifier:(NSString *)staticIdentifier completion:(void(^)(NSError *error))completion;

/**
 * This method has been deprecated.
 * Starts the mobile engagement service with environment.
 * @param maasAppId You can find your Application ID in the MaaS portal.
 * @param accessKey A unique key that identifies the client making the request. You can find your Access Key in the MaaS portal.
 * @param signatureKey A unique key that is used to sign requests. The signature is used to both check request authorization as well as data integrity. You can find your Signature Key in the MaaS portal.
 * @param encryptionKey The key used to encrypt and decrypt data that is exchanged between the client and the server. You can find your Encryption Key in the MaaS portal.
 * @param completion A block that notify mobile engagement service is successfully started or failed to start with reason.
 *      - *param1* error It's nil when it's started successfully, or an error object containing information about a problem that indicates mobile engagement service failed to start.
 */
+ (void)startWithMaasAppId:(NSString *)maasAppId
				 accessKey:(NSString *)accessKey
			  signatureKey:(NSString *)signatureKey
			 encryptionKey:(NSString *)encryptionKey
				completion:(void(^)(NSError *error))completion __deprecated;

@end
