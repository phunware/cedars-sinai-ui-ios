//
//  PWConsoleLogger.h
//  PWCore
//
//  Created on 3/19/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PWCore/PWLogger.h>

@interface PWConsoleLogger : NSObject <PWLogger>

/**
 * The name of the service that corresponds to the logger.
 * @discussion Each logger will only log messages tagged with the same service name as teh logger.
 */
@property (nonatomic,readonly) NSString * serviceName;
/**
 * The base level of the logger.
 * @discussion This property can be set to filter out log messages depending on their type. See the 'PWLogLevel' enum for more details.
 */
@property (nonatomic) PWLogLevel baseLevel;

/**
 * Indicates if the logger needs to execute in the background
 * @discussion If the property is true, the logMessage: method will be executed using an asynchronous dispatch queue
 */
@property (nonatomic,readonly) BOOL asyncLogging;

/**
 * Convenience constructor to create logger
 * @param serviceName The service name that corresponds to the logger.
 */
+ (instancetype)loggerWithServiceName:(NSString*)serviceName;

/**
 * Logs a message using the logger.
 * @discussion  Log messages whose type is lower than the logger base level will cause this method to be called
 */
- (void)logMessage:(PWLogMessage *)logMessage;

@end
