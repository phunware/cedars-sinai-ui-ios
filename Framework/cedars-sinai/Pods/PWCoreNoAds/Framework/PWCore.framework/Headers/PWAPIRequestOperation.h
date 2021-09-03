//
//  PWAPIRequestOperation.h
//  PWCore
//
//  Created by Illya Busigin on 8/10/15.
//  Copyright (c) 2015 Phunware. All rights reserved.
//

#import "PWAPIOperation.h"

@interface PWAPIRequestOperation : PWAPIOperation

@property (nonatomic, readonly, nonnull) NSURLRequest *request;

- (nonnull instancetype)initWithURLRequest:(nonnull NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

@end
