//
//  PWMapKit+Extensions.swift
//  ParkviewHealth
//
//  Created by Samuel Cornejo on 6/12/19.
//  Copyright © 2019 Parkview Health. All rights reserved.
//

import PWMapKit

extension PWPointOfInterest {
    /// A string of `keywords` by custom metaData.
    var keywords: String {
        guard let keywords = metaData?["keywords"] as? String else { return "" }
        return keywords
    }
    
    /// A string of `hours` by custom metaData.
    var hours: String {
        guard let metaData = metaData, let hours = metaData["hours"] as? String else { return "" }
        return hours
    }
    
    /// A string of `phone` by custom metaData.
    var phoneNumber: String {
        guard let metaData = metaData, let phone = metaData["phone"] as? String else { return "" }
        return phone
    }
    
    /// A string of `imageUrl` by custom metaData.
    var metadataImageURL: String {
        guard let metaData = metaData, let imageUrl = metaData["imageUrl"] as? String else { return "" }
        return imageUrl
    }
    
    /// A string of `url` by custom metaData.
    var url: String {
        guard let metaData = metaData, let url = metaData["url"] as? String else { return "" }
        return url
    }
}

extension PWMapView {
    func zoomToPOI(_ poi: PWPointOfInterest) {
        if currentFloor != poi.floor {
            currentFloor = poi.floor
        }
        
        setCameraZoom(coordinate: poi.coordinate)
        selectAnnotation(poi, animated: true)
    }
    
    func zoomToPOI(_ poi: PWUserLocation) {
        if currentFloor.floorID != poi.floorID {
            currentFloor = building.floor(byId: poi.floorID)
        }
        
        setCameraZoom(coordinate: poi.coordinate)
        selectAnnotation(poi, animated: true)
    }
    
    func setCameraZoom(coordinate: CLLocationCoordinate2D) {
            let camera = MKMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 1)  // POI zoom 200 right after grid
            setCamera(camera, animated: true)
    }
    
    func zoomToMapPoint(_ poi: PWMapPoint) {
        if currentFloor.floorID != poi.floorID {
            currentFloor = building.floor(byId: poi.floorID)
        }
        
        let center = CLLocationCoordinate2D(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.00025, longitudeDelta: 0.00025) // Routing zoom 0.0008 right after grid
        let region = MKCoordinateRegion(center: center, span: span)
        setRegion(region, animated: false)
    }
}

extension PWRouteInstructionDirection {
    var directionImage: UIImage {
        switch self {
        case .straight:
            return UIImage(named: "ic_straight_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        case .left:
            return UIImage(named: "ic_sharpleft_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        case .right:
            return UIImage(named: "ic_sharpright_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        case .bearLeft:
            return UIImage(named: "ic_slightleft_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        case .bearRight:
            return UIImage(named: "ic_slightright_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        case .floorChange:
            return UIImage(named: "ic_straight_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        case .elevatorUp:
            return UIImage(named: "ic_elevatorup_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        case .elevatorDown:
            return UIImage(named: "ic_elevatordown_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        case .stairsUp, .escalatorUp:
            return UIImage(named: "ic_stairup_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        case .stairsDown, .escalatorDown:
            return UIImage(named: "ic_stairdown_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        @unknown default:
            return UIImage(named:"ic_straight_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
        }
    }
}
