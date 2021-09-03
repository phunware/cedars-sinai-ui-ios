//
//  PWMEGeozone.h
//  PWEngagement
//
//  Copyright (c) 2015 Phunware, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "PWMEZoneProtocol.h"

/**
 * A PWMEGeozone object represents a circular region in a map with some associated data
 * for that region.
 */
@interface PWMEGeozone : NSObject <PWMEZone, NSSecureCoding, NSCopying>

/**
 The circular region represented by the PWMEGeozone object. (read-only)
 @discussion  When working with CLRegions, you should never perform pointer-level comparisons to determine equality. Instead, use the region’s identifier string to compare regions.
 */
@property (readonly, nonatomic) CLCircularRegion *region;

/**
 The geozone identifier. (read-only)
 */
@property (readonly, nonatomic) NSString * identifier;

/**
 The name given to the geozone object. (read-only)
 */
@property (readonly, nonatomic) NSString * name;

/**
 The code assigned to the geozone object. (read-only)
 */
@property (readonly, nonatomic) NSString * code;

/**
 The description assigned to the geozone object. (read-only)
 */
@property (readonly, nonatomic) NSString * zoneDescription;

/**
 A flag that indicates if the user is currently inside the geozone. (read-only)
 */
@property (readonly, nonatomic) BOOL inside;

/**
 * A flag that indicates if the zone is monitored. (read-only)
 */
@property (nonatomic, readonly) BOOL monitored;

/**
 A set of tags associated to the geozone. (read-only)
 */
@property (readonly, nonatomic) NSSet *tags;



/**
 * Unavailable initializer.
 */
- (instancetype)init NS_UNAVAILABLE;

@end
