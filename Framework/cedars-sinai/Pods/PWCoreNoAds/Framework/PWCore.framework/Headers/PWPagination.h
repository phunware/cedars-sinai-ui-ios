//
//  PWPagination.h

//
//  Copyright (c) 2013 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `PWPagination` objects encapsulate all pagination details associated with fetching an array of content objects.
 */

@interface PWPagination : NSObject

/**
 The starting index for the returned results.
 */
@property (nonatomic, readonly) NSUInteger fromResultIndex;

/**
 The ending index for the returned results.
 */
@property (nonatomic, readonly) NSUInteger toResultIndex;

/**
 The total number of available results.
 */
@property (nonatomic, readonly) NSUInteger totalResults;

/**
 The current results page.
 */
@property (nonatomic, readonly) NSUInteger currentPage;

/**
 The total number of results pages available.
 */
@property (nonatomic, readonly) NSUInteger numberOfPages;


///-----------------------
/// @name Convenience
///-----------------------

/**
 Convenience method to instantiate a `PWPagination` object from a properly formatted `NSDictionary` object.
 @param dictionary The dictionary from which to instantiate the `PWPagination` object.
 */

+ (instancetype)unpack:(NSDictionary *)dictionary;

@end
