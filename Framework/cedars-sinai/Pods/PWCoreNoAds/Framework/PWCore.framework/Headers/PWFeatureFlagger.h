//
//  PWFeatureFlagger.h
//  PWCore
//
//  Created on 5/29/18.
//  Copyright © 2018 Phunware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWFeatureFlagger : NSObject

- (instancetype __nonnull)init __unavailable;
+ (BOOL)featureEnabled:(NSString *__nonnull)featureName;
+ (void)enable:(BOOL)enable feature:(NSString *__nonnull)featureName;
+ (void)enableAllFeatures:(BOOL)enable;
+ (NSArray<NSString *> *__nullable)enabledFeatures:(BOOL)enabled;
+ (void)enable:(BOOL)enable features:(NSArray<NSString *> *__nonnull)featureNames;

+ (NSDictionary *__nullable)configurationsForFeature:(NSString *__nonnull)featureName;
+ (void)setConfiguration:(id __nonnull)configuration withKey:(NSString *__nonnull)key forFeature:(NSString *__nonnull)featureName;
+ (void)setConfigurations:(NSArray<id> *__nonnull)configurations withKeys:(NSArray<NSString *> *__nonnull)keys forFeature:(NSString *__nonnull)featureName;
+ (id __nullable)configurationWithKey:(NSString *__nonnull)key forFeature:(NSString *__nonnull)featureName;

@end
