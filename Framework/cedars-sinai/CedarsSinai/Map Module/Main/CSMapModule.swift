//
//  CSMapModule.swift
//  CedarsSinai
//
//  Created by tomas on 2/1/18.
//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation
import PWCore
import PWEngagement
import PWMapKit

internal func logger(_ message: String,
                     data: [AnyHashable: Any] = [:],
                     file: String = #file,
                     function: String = #function,
                     line: UInt = #line) {

    PWLogger.setLoggersLogLevel(.debug, forService: CSMapModule.serviceName)
    PWLogger.fileLoggingEnabled(true, forService: CSMapModule.serviceName)
    PWLogger.consoleLoggingEnabled(true, forService: CSMapModule.serviceName)

    PWLogger.log(forService: CSMapModule.serviceName, message: message, type: .debug, file: URL(string: file)?.lastPathComponent, function: function, line: line, dictionary: data)
}

public class CSMapModule {
    internal static let serviceName = "CedarsSinaiModule"

    internal static let ParkingPOIIdentifier = -2
    internal static let CurrentLocationIdentifier = -10
    internal static let alertDistance: CLLocationDistance = 7.62
    internal static let rerouteDistance: CLLocationDistance = 15.24

    /**
     Instantiates the map module's root view controller for the building.
     - Parameter buildingID: The building identifier to use for initialization.
     - Returns: CSMapModuleViewController
     */
    public static func initialViewController(withBuildingID buildingID: Int) -> CSMapModuleViewController {
        let viewController = UIStoryboard(name: String(describing: CSMapModuleViewController.self), bundle: CSBundleHelper.bundle).instantiateInitialViewController() as! CSMapModuleViewController
        viewController.buildingID = buildingID
        return viewController
    }

    /**
     Instantiates the map module's root view controller and then present the route builder.
     - Parameter buildingID: The building identifier to use for initialization.
     - Parameter poiID: You can optionally pass the destination POI identifier.
     - Returns: CSMapModuleViewController
     */
    public static func initialRouteBuilder(withBuildingID buildingID: Int, poiID: Int? = nil) -> CSMapModuleViewController {
        let viewController = initialViewController(withBuildingID: buildingID)
        viewController.presentRouteBuilder = true
        viewController.poiDetailID = poiID
        return viewController
    }
    
    /**
     Fetches the building data and caches it.
     - Parameter buildingID: The building identifier to use for initialization.
     - Parameter completion: Returns an error if the building failed to load. Otherwise the error is nil.
     */
    public static func loadBuilding(withBuildingID buildingID: Int, completion: ((Error?) -> Void)?) {
        PWBuilding.building(withIdentifier: buildingID) { (building, error) in
            if error != nil {
                completion?(error)
            } else {
                completion?(nil)
            }
        }
    }
    
    /**
     Opens the app's settings.
     */
    public static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
    }

    internal static func userIsInsideZones() -> Bool {
        return PWEngagement.insideZones().count > 0
    }

//    internal static func sendEvent(_ name: Event.Name, parameters: [Event.Parameter: String]) {
//        PWAnalytics.addEvent(name.rawValue, withParameters: parameters)
//    }
//    
    internal static func sentEvent(_ eventName: String) {
        PWAnalytics.addEvent(eventName)
    }
    
    internal static func sendEvent(_ eventName: String, paramaters: [String: String]) {
        PWAnalytics.addEvent(eventName, withParameters: paramaters)
    }

    static func startEvent(_ eventName: String, parameters: [String: String]? = nil) {
        PWAnalytics.startTimedEvent(eventName, withParameters: parameters)
    }

    static func endEvent(_ eventName: String, parameters: [String: String]? = nil) {
        PWAnalytics.endTimedEvent(eventName, withParameters: parameters)
    }

    internal static func localizedString(_ string: String) -> String? {
        return NSLocalizedString(string,
                                 tableName: "CedarsSinai",
                                 bundle: CSBundleHelper.bundle,
                                 comment: "")
    }

}

internal struct Event {
    enum Name: String, CustomStringConvertible {
        case screenView = "Screen View"
        case buttonTapped = "Button Tapped"
        case route = "Route"
        case search = "Search"

        var description: String {
            return self.rawValue
        }
    }

    enum Parameter: String, CustomStringConvertible {
        case screenName = "Screen Name"
        case buttonName = "Button Name"
        case routeFrom = "From"
        case routeTo = "To"

        var description: String {
            return self.rawValue
        }
    }
}

