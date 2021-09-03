//
//  PWBundleManager.m
//  Azul
//
//  Created by Xiangwei Wang on 07/11/2016.
//  Copyright © 2016 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Completion block for a bundle fetch.
 */
typedef void(^PWBundleFetchCompletion)(NSString *bundleDirectory, NSDictionary *userInfo, NSError *error);

/*
 Key for userInfo in PWBundleFetchCompletion that explains why a failure to update the bundle occurred.
 */
extern NSString * const PWBundleUpdateFailureKey;
/*
 Key for userInfo in PWBundleFetchCompletion that reports if the bundle was changed or if it was taken from cache.
 */
extern NSString * const PWBundleChangedKey;

/**
 A generic class for download/decrypt/unzip a bundle for specific URL.
 */
@interface PWBundleManager : NSObject

/**
 The timeout for network request to get the bundle before falling back to the cached version. This is only used if a cached bundle exists, for non-cached bundles the default of 60 seconds is used. If this is not set at all, the default of 10 seconds is used.
 */
@property (nonatomic) NSTimeInterval cacheFallbackTimeoutOverride;

/**
 Shared `PWBundleManager`.
 */
+ (PWBundleManager *)sharedInstance;

/**
 Remove the bundle for a specific url.
 @param url The specific url for which you want to remove.
 */
- (void)removeBundleForURL:(NSURL *)url;

/**
 Fetch an unencrypted bundle from the url, unpack it, and save the necessary JSON files
 @param url The url that the manager should load.
 @param completion A block that returns the unzipped bundle directory or error.
 */
- (void)fetchBundleWithURL:(NSURL *)url withCompletion:(PWBundleFetchCompletion)completion;

/**
 Fetch an encrypted bundle from the url, decprypt then unpack it, and save the necessary JSON files
 @param url The url that the manager should load.
 @param decryptionKey The key used to deprypt the bundle.
 @param completion A block that returns information about the bundle fetch and the unzipped bundle directory or error.
 */
- (void)fetchBundleWithURL:(NSURL *)url decryptionKey:(NSString *)decryptionKey withCompletion:(PWBundleFetchCompletion)completion;

/**
 Fetch an unencrypted bundle from the url, unpack it, and save the necessary JSON files
 @param url The url that the manager should load.
 @param retryInterval The interval to attempt retry.
 @param maxRetry The maximum no of times to retry.
 @param completion A block that returns information about the bundle fetch and the unzipped bundle directory or error.
 */
- (void)fetchBundleWithURL:(NSURL *)url retryInterval:(NSInteger)retryInterval maxRetry:(NSInteger)maxRetry withCompletion:(PWBundleFetchCompletion)completion;

/**
 Fetch an encrypted bundle from the url, decprypt then unpack it, and save the necessary JSON files
 @param url The url that the manager should load.
 @param decryptionKey The key used to deprypt the bundle.
 @param retryInterval The interval to attempt retry.
 @param maxRetry The maximum no of times to retry.
 @param completion A block that returns information about the bundle fetch and the unzipped bundle directory or error.
 */
- (void)fetchBundleWithURL:(NSURL *)url retryInterval:(NSInteger)retryInterval maxRetry:(NSInteger)maxRetry decryptionKey:(NSString *)decryptionKey withCompletion:(PWBundleFetchCompletion)completion;

/**
 Fetch building bundle for the specified building identifier, decprypt then unpack it, and save the necessary JSON files
 @param buildingId The building identifier.
 @param isDraft Tell it's a draft or live bundle.
 @param completion A block that returns information about the bundle fetch and the unzipped bundle directory or error.
 */
- (void)fetchBuildingBundleById:(NSInteger)buildingId draft:(BOOL)isDraft withCompletion:(PWBundleFetchCompletion)completion;

#pragma mark - Deprecated

/**
 Fetch an unencrypted bundle from the url, unpack it, and save the necessary JSON files
 @param url The url that the manager should load.
 @param completion A block that returns the unzipped bundle directory or error.
 */
- (void)fetchBundleWithURL:(NSURL *)url completion:(void(^)(NSString *bundleDirectory, BOOL bundleChanged, NSError *error))completion __deprecated;

/**
 Fetch an encrypted bundle from the url, decprypt then unpack it, and save the necessary JSON files
 @param url The url that the manager should load.
 @param decryptionKey The key used to deprypt the bundle.
 @param completion A block that returns the unzipped bundle directory or error.
 */
- (void)fetchBundleWithURL:(NSURL *)url decryptionKey:(NSString *)decryptionKey completion:(void(^)(NSString *bundleDirectory, BOOL bundleChanged, NSError *error))completion __deprecated;

/**
 Fetch an unencrypted bundle from the url, unpack it, and save the necessary JSON files
 @param url The url that the manager should load.
 @param retryInterval The interval to attempt retry.
 @param maxRetry The maximum no of times to retry.
 @param completion A block that returns the unzipped bundle directory or error.
 */
- (void)fetchBundleWithURL:(NSURL *)url retryInterval:(NSInteger)retryInterval maxRetry:(NSInteger)maxRetry completion:(void(^)(NSString *bundleDirectory, BOOL bundleChanged, NSError *error))completion __deprecated;

/**
 Fetch an encrypted bundle from the url, decprypt then unpack it, and save the necessary JSON files
 @param url The url that the manager should load.
 @param decryptionKey The key used to deprypt the bundle.
 @param retryInterval The interval to attempt retry.
 @param maxRetry The maximum no of times to retry.
 @param completion A block that returns the unzipped bundle directory or error.
 */
- (void)fetchBundleWithURL:(NSURL *)url retryInterval:(NSInteger)retryInterval maxRetry:(NSInteger)maxRetry decryptionKey:(NSString *)decryptionKey completion:(void(^)(NSString *bundleDirectory, BOOL bundleChanged, NSError *error))completion __deprecated;

/**
 Fetch building bundle for the specified building identifier, decprypt then unpack it, and save the necessary JSON files
 @param buildingId The building identifier.
 @param isDraft Tell it's a draft or live bundle.
 @param completion A block that returns the unzipped bundle directory or error.
 */
- (void)fetchBuildingBundleById:(NSInteger)buildingId draft:(BOOL)isDraft completion:(void(^)(NSString *bundleDirectory, BOOL bundleChanged, NSError *error))completion __deprecated;
@end
