//
//  CSLocationStatusHelper.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/2/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import CoreLocation

struct CSLocationStatusHelper {
    public static func locationServicesAvailable() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
    
    public static func shouldShowRoutinPrompt(userLocation: CLLocationCoordinate2D, buildingLocation: CLLocationCoordinate2D) -> Bool {
        let userPosition = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let buildingPosition = CLLocation(latitude: buildingLocation.latitude, longitude: buildingLocation.longitude)
        
        let distance = userPosition.distance(from: buildingPosition)
        return distance > 200 //Meters
    }
}
