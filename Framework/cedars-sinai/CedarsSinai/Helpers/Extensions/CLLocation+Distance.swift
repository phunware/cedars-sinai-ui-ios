//
//  CLLocation+Distance.swift
//  CedarsSinai
//
//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    func magnitude(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        let latitude = end.latitude - start.latitude
        let longitude = end.longitude - start.longitude
        let vector = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return sqrt(pow(vector.latitude, 2) + pow(vector.longitude, 2))
    }

    func distanceFromLineWithPoints(from start: CLLocation, to end: CLLocation) -> CLLocationDistance {
        let lineMagnitude = magnitude(from: start.coordinate, to: end.coordinate)


        let U: Double = ( ( ( self.coordinate.latitude - start.coordinate.latitude ) * ( end.coordinate.latitude - start.coordinate.latitude ) ) +
            ( ( self.coordinate.longitude - start.coordinate.longitude ) * ( end.coordinate.longitude - start.coordinate.longitude ) ) ) / pow(lineMagnitude, 2)

        if U < 0 {
            return distance(from: start)
        }
        else if U > 1 {
            return distance(from: end)
        }

        let latitude = start.coordinate.latitude + U * ( end.coordinate.latitude - start.coordinate.latitude )
        let longitude = start.coordinate.longitude + U * ( end.coordinate.longitude - start.coordinate.longitude )

        let point = CLLocation(latitude: latitude, longitude: longitude)
        return distance(from: point)
    }
}
