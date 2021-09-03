//
//  PWAnalytics.h
//  PWAnalytics
//
//  Copyright (c) 2015 Phunware. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `PWAnalytics` enables easy implementation of application workflow analytics. MaaSAnalytics supports standard analytics events, timed events and event parameters.
 */

@interface PWAnalytics : NSObject

///-----------------------
/// @name Event Methods
///-----------------------

/**
 Add an event to the analytics queue.
 @param eventName Name of the event. 
 */
+ (void)addCustomEvent:(NSString *__nonnull)eventName;

/**
 Add an event to the analytics queue. Parameters must follow these rules:
 (1) Keys and values must be NSString objects.
 (2) There may be no more than 5 parameters. Extra parameters will be ignored.
 (3) Each key or value that is longer than 40 characters will be truncated on server.
 @param eventName Name of the event.
 @param parameters `NSString` key / value parameters. For example, `@{@"key" : @"value"}`.
 */
+ (void)addCustomEvent:(NSString *__nonnull)eventName withParameters:(NSDictionary<NSString *, NSString *> *__nullable)parameters;

/**
 Set a screen name for automatic screen view events. This should be set in the `viewWillAppear` callback of your view controller before calling `super viewWillAppear`.
 @param screenName Screen name for the view event.
 */
+ (void)setScreenName:(NSString *__nonnull)screenName;

/**
 Set an app section for automatic screen view events. This should be set in the `viewWillAppear` callback of your view controller before calling `super viewWillAppear`.
 @param appSection App section for the view event.
 */
+ (void)setAppSection:(NSString *__nullable)appSection;

/**
 Set global parameters for all events. This should be set in the `viewWillAppear` callback of your view controller before calling `super viewWillAppear`.
 @param parameters Parameters included for all events until cleared.
 */
+ (void)setGlobalParameters:(NSDictionary<NSString *, NSString *> *__nullable)parameters;

/**
 Determines whether automatic screen views are captured.
 @param enable Will automatically capture screen view events or not. Defaults to enabled.
 */
+ (void)enableAutomaticScreenViewEvents:(BOOL)enable;

#pragma mark - Deprecated Methods

/**
 Add an event to the analytics queue.
 @param eventName Name of the event.
 */
+ (void)addEvent:(NSString *__nonnull)eventName __deprecated;

/**
 Add an event to the analytics queue.
 @param eventName Name of the event.
 @param eventNamespace The namespace of the analytic event. Used for custom event processing.
 */
+ (void)addEvent:(NSString *__nonnull)eventName eventNamespace:(NSString *__nonnull)eventNamespace __deprecated;

/**
 Add an event to the analytics queue. Parameters must follow these rules:
 (1) Keys and values must be `NSString` objects.
 (2) There may be no more than 10 parameters. Extra parameters will be ignored.
 (3) Each key or value that is longer than 256 characters will be truncated.
 @param eventName Name of the event.
 @param parameters `NSString` key / value parameters. For example, `@{@"key" : @"value"}`.
 */
+ (void)addEvent:(NSString *__nonnull)eventName withParameters:(NSDictionary<NSString *, NSString *> *__nullable)parameters __deprecated;

/**
 Add an event to the analytics queue. Parameters must follow these rules:
 (1) Keys and values must be `NSString` objects.
 (2) There may be no more than 10 parameters. Extra parameters will be ignored.
 (3) Each key or value that is longer than 256 characters will be truncated.
 @param eventName Name of the event.
 @param parameters `NSString` key / value parameters. For example, `@{@"key" : @"value"}`.
 @param eventNamespace The namespace of the analytic event. Used for custom event processing.
 */
+ (void)addEvent:(NSString *__nonnull)eventName withParameters:(NSDictionary<NSString *, NSString *> *__nullable)parameters eventNamespace:(NSString *__nullable)eventNamespace __deprecated;

/**
 Start a timed event. Calling `startTimedEvent:` with the same `eventName` prior to `endTimedEvent:` will overwrite the previous start time.
 @param eventName Name of the event to start.
 */
+ (void)startTimedEvent:(NSString *__nonnull)eventName __deprecated;

/**
 Start a timed event. Calling `startTimedEvent:` with the same `eventName` prior to `endTimedEvent:` will overwrite the previous start time.
 @param eventName Name of the event to start.
 @param eventNamespace The namespace of the analytic event. Used for custom event processing.
 */
+ (void)startTimedEvent:(NSString *__nonnull)eventName eventNamespace:(NSString *__nullable)eventNamespace __deprecated;

/**
 Start a timed event with the specified parameters. Calling `startTimedEvent:` with the same `eventName` prior to `endTimedEvent:` will overwrite the previous start time. Parameters must follow these rules:
 (1) Keys and values must be `NSString` objects.
 (2) There may be no more than 10 parameters. Extra parameters will be ignored.
 (3) Each key or value that is longer than 256 characters will be truncated.
 @param eventName Name of the event to start.
 @param parameters `NSString` key / value parameters. For example, `@{@"key" : @"value"}`.
 */
+ (void)startTimedEvent:(NSString *__nonnull)eventName withParameters:(NSDictionary<NSString *, NSString *> *__nullable)parameters __deprecated;

/**
 Start a timed event with the specified parameters. Calling `startTimedEvent:` with the same `eventName` prior to `endTimedEvent:` will overwrite the previous start time. Parameters must follow these rules:
 (1) Keys and values must be `NSString` objects.
 (2) There may be no more than 10 parameters. Extra parameters will be ignored.
 (3) Each key or value that is longer than 256 characters will be truncated.
 @param eventName Name of the event to start.
 @param parameters `NSString` key / value parameters. For example, `@{@"key" : @"value"}`.
 @param eventNamespace The namespace of the analytic event. Used for custom event processing.
 */
+ (void)startTimedEvent:(NSString *__nonnull)eventName withParameters:(NSDictionary<NSString *, NSString *> *__nullable)parameters eventNamespace:(NSString *__nullable)eventNamespace __deprecated;

/**
 Pause a timed event with the specified `eventName`. If an event is ended while still in a paused state, then the paused time will be used as the end time. If an event is already paused, this method will do nothing.
 @param eventName The name of the event to pause.
 */
+ (void)pauseTimedEvent:(NSString *__nonnull)eventName __deprecated;

/**
 Resume a timed event with the specified `eventName`. If an event is ended while still in a paused state, then the paused time will be used as the end time. If an event is already paused, this method will do nothing.
 @param eventName The name of the event to resume.
 */
+ (void)resumeTimedEvent:(NSString *__nonnull)eventName __deprecated;

/**
 End a timed event with the specified `eventName`. The event will be ignored if the event duration is less than one second. This method will do nothing if the event name cannot be found.
 @param eventName The name of the event to end.
 */
+ (void)endTimedEvent:(NSString *__nonnull)eventName __deprecated;

/**
 End a timed event with the specified `eventName`. The event will be ignored if the event duration is less than one second. This method will do nothing if the event name cannot be found. Parameters must follow these rules:
 (1) Keys and values must be `NSString` objects.
 (2) There may be no more than 10 parameters. Extra parameters will be ignored.
 (3) Each key or value that is longer than 256 characters will be truncated.
 @param eventName The name of the event to end.
 @param parameters `NSString` key / value parameters. For example, `@{@"key" : @"value"}`.
 */
+ (void)endTimedEvent:(NSString *__nonnull)eventName withParameters:(NSDictionary<NSString *, NSString *> *__nullable)parameters __deprecated;

/**
 End a timed event with the specified `eventName`. The event will be ignored if the event duration is less than one second. This method will do nothing if the event name cannot be found. Parameters must follow these rules:
 (1) Keys and values must be `NSString` objects.
 (2) There may be no more than 10 parameters. Extra parameters will be ignored.
 (3) Each key or value that is longer than 256 characters will be truncated.
 @param eventName The name of the event to end.
 @param parameters `NSString` key / value parameters. For example, `@{@"key" : @"value"}`.
 @param eventNamespace The namespace of the analytic event. Used for custom event processing.
 */
+ (void)endTimedEvent:(NSString *__nonnull)eventName withParameters:(NSDictionary<NSString *, NSString *> *__nullable)parameters eventNamespace:(NSString *__nullable)eventNamespace __deprecated;

@end
