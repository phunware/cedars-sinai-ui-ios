//
//  CSNotificationNamesHelper.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/6/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import Foundation
import PWMapKit

struct CSNotificationNamesHelper {
    
    public static let PWRouteInstructionChanged = Notification.Name(PWRouteInstructionChangedNotificationKey)
    public static let startNavigatingRoute = Notification.Name("startNavigatingRoute")
    public static let plotRoute = Notification.Name("PlotRouteNotification")
    public static let resetMapView = Notification.Name("ResetMapView")
    public static let mapSearchTapped = Notification.Name("MapSearchTapped")
    
}

extension Notification.Name {
    public static let UserDidAddParkingPOI = Notification.Name("UserDidAddParkingPOI")
    public static let UserDidRemoveParkingPOI = Notification.Name("UserDidRemoveParkingPOI")
    public static let MapViewDidAppear = Notification.Name("MapViewDidAppear")
    public static let FirstLocationAcquired = Notification.Name("FirstLocationAcquired")
}
