//
//  PWLogMessage.h
//  PWCore
//
//  Created on 3/19/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWLoggableObject.h"

typedef NS_ENUM(NSUInteger, PWLogType) {
    PWLogTypeError,
    PWLogTypeWarning,
    PWLogTypeInfo,
    PWLogTypeDebug
};

@interface PWLogMessage : NSObject <NSCopying, PWLoggableObject>

/**
 * The main message of the message object.
 */
@property (nonatomic, readonly) NSString *message;

/**
 * A dictionary with the log message details.
 */
@property (nonatomic, readonly) NSDictionary* details;

/**
 * The name of the service that corresponds to the message.
 */
@property (nonatomic, readonly) NSString *serviceName;

/**
 * The type of log message. Whether the message will actually be logged depends on the type of the message and the level of the logger. Refer to the 'PWLogLevel' enum for details.
 */
@property (nonatomic, readonly) PWLogType logType;

/**
 * The file where the message was logged.
 */
@property (nonatomic, readonly) NSString *file;

/**
 * The function where the message was logged.
 */
@property (nonatomic, readonly) NSString *function;

/**
 * The line number inside the file where the message was logged.
 */
@property (nonatomic, readonly) NSUInteger line;

/**
 * The date the message was logged.
 */
@property (nonatomic, readonly) NSDate *timestamp;

/**
 * Initializes a log message object.
 * @param message The main message of the log messge object
 * @param details The log message details
 * @param serviceName The name of the service that corresponds to the message.
 * @param type The type of log message.
 * @param file The file where the message was logged.
 * @param function The function where the message was logged.
 * @param line The line number inside the file where the message was logged.
 * @return An instance of a log message object.
 */
- (instancetype)initWithMessage:(NSString *)message
                        details:(NSDictionary *)details
                    serviceName:(NSString *)serviceName
                           type:(PWLogType)type
                           file:(NSString *)file
                       function:(NSString *)function
                           line:(NSUInteger)line;
/**
 * The JSON representation of the log message.
 * @returns A string containing the JSON representation of the log message.
 */
- (NSString *)jsonRepresentation;

@end
