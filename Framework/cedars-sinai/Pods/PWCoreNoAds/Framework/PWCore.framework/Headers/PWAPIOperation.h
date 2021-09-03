//
//  PWAPIOperation.h
//  PWCore
//
//  Created by Illya Busigin on 8/10/15.
//  Copyright (c) 2015 Phunware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PWAPIOperation;

typedef void (^PWAPIOperationSuccess)(PWAPIOperation *__nonnull operation, id __nullable responseObject);
typedef void (^PWAPIOperationFailure)(PWAPIOperation *__nonnull operation, NSError *__nonnull error);

@protocol PWAPIRequest <NSObject>

@property (nonatomic, copy, nonnull) NSURL *URL;
@property (nonatomic, copy, nonnull) NSString *HTTPMethod;
@property (nonatomic, copy, nonnull) id parameters;
@property (nonatomic, copy, nonnull) NSDictionary *allHTTPHeaderFields;

@property (nonatomic, copy, nullable) PWAPIOperationSuccess successBlock;
@property (nonatomic, copy, nullable) PWAPIOperationFailure failureBlock;

@end

NS_ASSUME_NONNULL_BEGIN

@interface PWAPIOperation : NSOperation <PWAPIRequest>

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) NSString *HTTPMethod;
@property (nonatomic, copy) id parameters;
@property (nonatomic, copy) NSDictionary *allHTTPHeaderFields;

@property (nonatomic, copy, nullable) PWAPIOperationSuccess successBlock;
@property (nonatomic, copy, nullable) PWAPIOperationFailure failureBlock;

@end

NS_ASSUME_NONNULL_END
