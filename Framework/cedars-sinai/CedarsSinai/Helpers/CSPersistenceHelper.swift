//
//  CSPersistenceHelper.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/12/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import CoreLocation
import PWMapKit

internal class CSPersistenceHelper {
    
    fileprivate static let kCSUserLatitudeKey = "UserLatitude"
    fileprivate static let kCSUserLongitudeKey = "UserLongitude"
    fileprivate static let kCSUserFloorId = "FloorID"
    fileprivate static let kCSUserBuildingId = "BuidldingID"

    fileprivate static let kCSRouteBuildingId = "RouteBuidldingID"
    fileprivate static let kCSRouteStartPointId = "RouteStartPointId"
    fileprivate static let kCSRouteEndPointId = "RouteEndPointId"
    fileprivate static let kCSRouteCurrentLocation = "RouteCurrentLocation"

    static let defaults = UserDefaults.standard
    
    //MARK: - Location Persistence
    internal static func clearSavedLocation() {
        defaults.removeObject(forKey: kCSUserLatitudeKey)
        defaults.removeObject(forKey: kCSUserLongitudeKey)
        defaults.removeObject(forKey: kCSUserFloorId)
        defaults.removeObject(forKey: kCSUserBuildingId)
    }
    
    internal static func saveLocation(_ location: CLLocationCoordinate2D, floorId: Int, buildingId: Int) {
            defaults.set(location.latitude, forKey: kCSUserLatitudeKey)
            defaults.set(location.longitude, forKey: kCSUserLongitudeKey)
            defaults.set(floorId, forKey: kCSUserFloorId)
            defaults.set(buildingId, forKey: kCSUserBuildingId)
    }

    internal static func location() -> (CLLocationCoordinate2D, Int, Int)? {
        guard let latitude = defaults.object(forKey: kCSUserLatitudeKey) as? Double,
        let longitude = defaults.object(forKey: kCSUserLongitudeKey) as? Double,
        let floorId = defaults.object(forKey: kCSUserFloorId) as? Int,
        let buildingId = defaults.object(forKey: kCSUserBuildingId) as? Int else {
            return nil
        }

        return (CLLocationCoordinate2D(latitude: latitude, longitude: longitude), floorId, buildingId)
    }

    internal static func save(route: PWRoute, currentLocation: Bool = false) {
        defaults.set(route.building.identifier, forKey: kCSRouteBuildingId)
        defaults.set(route.startPoint.identifier, forKey: kCSRouteStartPointId)
        defaults.set(route.endPoint.identifier, forKey: kCSRouteEndPointId)
        defaults.set(currentLocation, forKey: kCSRouteCurrentLocation)
    }

    internal static func routeStartPointID() -> Int {
        return defaults.integer(forKey: kCSRouteStartPointId)
    }

    internal static func routeEndPointID() -> Int {
        return defaults.integer(forKey: kCSRouteEndPointId)
    }

    internal static func routeFromCurrentLocation() -> Bool {
        return defaults.bool(forKey: kCSRouteCurrentLocation)
    }

    internal static func clearRoute() {
        defaults.removeObject(forKey: kCSRouteBuildingId)
        defaults.removeObject(forKey: kCSRouteStartPointId)
        defaults.removeObject(forKey: kCSRouteEndPointId)
        defaults.removeObject(forKey: kCSRouteCurrentLocation)
    }

    internal static func routFromCurrentLocation() -> Bool {
        return defaults.bool(forKey: kCSRouteCurrentLocation)
    }
}
