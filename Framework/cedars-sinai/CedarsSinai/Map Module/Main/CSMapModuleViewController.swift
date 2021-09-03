//
//  CSMapModuleViewController.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/12/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit
import CoreBluetooth
import MBProgressHUD

public class CSMapModuleViewController: UIViewController {

    @IBOutlet weak var referenceView: UIView!
    @IBOutlet weak var segmentedControl: CSSegmentedControl!

    internal var buildingID: Int?
    internal var poiDetailID: Int?

    internal var presentRouteBuilder: Bool = false
    internal var locationTimer: Timer?

    fileprivate let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    fileprivate let mapViewController = UIStoryboard(name: String(describing: CSMapViewController.self), bundle: CSBundleHelper.bundle).instantiateInitialViewController() as? CSMapViewController
    fileprivate let directoryListViewController = UIStoryboard(name: String(describing: CSDirectoryListViewController.self), bundle: CSBundleHelper.bundle).instantiateInitialViewController() as? CSDirectoryListViewController

    fileprivate var buildingHud: MBProgressHUD?
    fileprivate var hud: MBProgressHUD?
    fileprivate let locationManager = CLLocationManager()
    fileprivate var bluetoothManager: CBCentralManager?
//    fileprivate var isCBCentralManagerPowerAlertShown: Bool = false

    public var currentUserLocationInMap: PWUserLocation? {
        get {
            return mapViewController?.mapView.indoorUserLocation
        }
    }

    lazy var notificationCenter = NotificationCenter.default
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        segmentedControl.items = ["MAP", "DIRECTORY"]
        mapViewController?.containerViewController = self
        directoryListViewController?.containerViewController = self

        if let mapViewController = mapViewController, let directoryViewController = directoryListViewController {
            addChild(mapViewController)
            addChild(directoryViewController)
        }

        setUpPageController()
        checkForPermissions()


        if let buildingID = buildingID {
            loadMapBuilding(buildingID)
        } else if let mapConfigurationPlist = CSPlistReader.dictionary(plistName: "MapConfig", inBundle: Bundle.main) ?? CSPlistReader.dictionary(plistName: "MapConfig"),
            let buildingID = mapConfigurationPlist["buildingID"] as? Int  {
            loadMapBuilding(buildingID)
        }

        notificationCenter.addObserver(self, selector: #selector(mapSearchWasTapped),
                                       name: CSNotificationNamesHelper.mapSearchTapped,
                                       object: nil)
        notificationCenter.addObserver(self, selector: #selector(firstLocationWasAcquired(notification:)),
                                       name: .FirstLocationAcquired,
                                       object: nil)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageViewController.view.frame = referenceView.frame
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    //MARK: - Outlet Actions
    @IBAction func segmentedControlTapped(_ sender: CSSegmentedControl) {
        changeViewControllerPage(viewControllerIndex: sender.selectedSegmentIndex)

        // Report the tab name tapped
        let buttonName = sender.buttons[sender.selectedSegmentIndex].titleLabel?.text ?? ""
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : buttonName])
    }

    //MARK: - Search Interaction
    @objc fileprivate func mapSearchWasTapped(notificatin: Notification) {
        segmentedControl.changeSelectedSegmented(index: 1)
        directoryListViewController?.searchTextField.becomeFirstResponder()
    }

    fileprivate func shouldPresentRouteBuilder() {
        if presentRouteBuilder {
            var poi: PWPointOfInterest?
            if let poiID = poiDetailID {
                poi = mapViewController?.currentBuilding.poiWith(identifier: poiID)
            }
            mapViewController?.presentRoutingView(destinationPOI: poi)
            presentRouteBuilder = false
        }
    }

    fileprivate func shouldWaitForLocation () {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.label.text = "Acquiring your location"
        hud?.isUserInteractionEnabled = true

//        #if !(arch(i386) || arch(x86_64))
//        locationTimer = Timer.scheduledTimer(timeInterval: 30,
//                                             target: self,
//                                             selector: #selector(locationTimerFinished(timer:)),
//                                             userInfo: nil,
//                                             repeats: false)
//        #else
        locationTimer = Timer.scheduledTimer(timeInterval: 60,
                                             target: self,
                                             selector: #selector(locationTimerFinished(timer:)),
                                             userInfo: nil,
                                             repeats: false)
//        #endif
    }

    // MARK: - Location
    @objc fileprivate func firstLocationWasAcquired(notification: Notification) {
        hud?.hide(animated: true)
        locationTimer?.invalidate()
        locationTimer = nil

        shouldPresentRouteBuilder()
    }

    @objc fileprivate func locationTimerFinished(timer: Timer) {
        hud?.hide(animated: true)
        locationTimer?.invalidate()
        locationTimer = nil
        shouldPresentRouteBuilder()
    }

    fileprivate func checkForPermissions() {
        checkBluetoothPermission()
        checkLocationPermission()
    }
    fileprivate func checkBluetoothPermission() {
        bluetoothManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }

    fileprivate func checkLocationPermission() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        default:
            promptForLocationNotGranted()
        }
    }

    fileprivate func promptForLocationNotGranted() {
        let alert = UIAlertController(title: "Location Permission", message: "Your location is needed for indoor routing.", preferredStyle: .alert)

        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            CSMapModule.openSettings()
        }

        alert.addAction(openSettingsAction)

        let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)


        present(alert, animated: true)
    }
    
//    fileprivate func promptForBluetoothNotOn() {
//        let alert = UIAlertController(title: "Location Accuracy", message: "Turning on Bluetooth will improve location accuracy.", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(okAction)
//        present(alert, animated: true)
//    }

}


//MARK: - Views Configuration
extension CSMapModuleViewController {
    fileprivate func loadMapBuilding(_ buildingID: Int) {
        buildingHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        PWBuilding.building(withIdentifier: buildingID) { [weak self] (building, error) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.buildingHud?.hide(animated: true)
            }
            guard let fetchedBuilding = building else {
                return
            }
            strongSelf.mapViewController?.currentBuilding = fetchedBuilding
            strongSelf.directoryListViewController?.currentBuilding = fetchedBuilding
            strongSelf.segmentedControl.isUserInteractionEnabled = true

            // ProgressHUD dismisses location permission prompt
            if (CSMapModule.userIsInsideZones()) {
                strongSelf.shouldWaitForLocation()
            }
        }
    }
    
    fileprivate func setUpPageController() {
        guard let currentMapViewController = mapViewController else {
            return
        }
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = referenceView.frame
        pageViewController.setViewControllers([currentMapViewController], direction: .forward, animated: false)
    }
    
    fileprivate func changeViewControllerPage(viewControllerIndex: Int) {
        guard let currentMapViewController = mapViewController, let currentDirectoryListViewController = directoryListViewController else {
            return
        }
        if viewControllerIndex == 0 {
            pageViewController.setViewControllers([currentMapViewController], direction: .reverse, animated: false)
        } else {
            pageViewController.setViewControllers([currentDirectoryListViewController], direction: .forward, animated: false)
        }
    }
}

// MARK: - RouteSelectedPointOfInterestDelegate
extension CSMapModuleViewController: RouteSelectedPointOfInterestDelegate {
    func routeToPointOfInterest(_ poi: PWMapPoint) {
        guard let currentMapViewController = mapViewController else {
            return
        }
        pageViewController.setViewControllers([currentMapViewController], direction: .reverse, animated: false)
        segmentedControl.changeSelectedSegmented(index: 0)

        if let currentLocation = currentUserLocationInMap {
            presentRoutingMapView(startPoi: currentLocation, endPoi: poi, fromCurrentLocation: true)
        } else {
            currentMapViewController.routeToPointOfInterest(poi)
        }
    }
}

// MARK: - Child View Controller Methods
extension CSMapModuleViewController {

    internal func presentRoutingMapView(_ building: PWBuilding) {

        if presentRouteBuilder {
            CSPersistenceHelper.clearRoute()
            logger("Clear saved route as it should present route builder")
            return
        }

        logger("present routing mapview")

        let startPoiId = CSPersistenceHelper.routeStartPointID()
        let endPoiId = CSPersistenceHelper.routeEndPointID()
        logger("Building data", data: ["start": startPoiId, "end": endPoiId, "building": building.identifier, "poiList": (building.allPointOfinterest() ?? "")])

        if startPoiId == CSMapModule.ParkingPOIIdentifier {
            guard let startPoi = building.poiWith(identifier: startPoiId),
            let parkingPoi = mapViewController?.parkingAnnotation else {
                logger("Parking POI not available")
                return
            }

            presentRoutingMapView(startPoi: startPoi, endPoi: parkingPoi)

        } else if endPoiId == CSMapModule.ParkingPOIIdentifier {
            guard let parkingPoi = mapViewController?.parkingAnnotation,
                let endPoi = building.poiWith(identifier: startPoiId) else {
                logger("Parking POI not available")
                    return
            }

            presentRoutingMapView(startPoi: parkingPoi, endPoi: endPoi)

        } else if CSPersistenceHelper.routeFromCurrentLocation() {
            guard let startPoi = mapViewController?.currentLocation,
                let endPoi = building.poiWith(identifier: endPoiId) else {
                    logger("Current location not available")
                    return
            }

            presentRoutingMapView(startPoi: startPoi, endPoi: endPoi)

        } else {
            guard let startPoi = building.poiWith(identifier: startPoiId),
                let endPoi = building.poiWith(identifier: endPoiId) else {
                    let poiList = building.allPointOfinterest()?.compactMap({ (poi) -> String in
                        "\(poi.identifier) \(poi.title)"
                    })
                    logger("POI not available", data: ["start": startPoiId, "end": endPoiId, "building": building.identifier, "poiList": (poiList ?? "")])
                    return
            }

            presentRoutingMapView(startPoi: startPoi, endPoi: endPoi)

        }

    }

    internal func presentRoutingMapView(startPoi: PWMapPoint, endPoi: PWMapPoint, fromCurrentLocation: Bool = false) {
        // Create a PWRouteOptions with landmarksEnabled set to true so landmarks will be injected into route info (if available).
        let routeOptions = PWRouteOptions(accessibilityEnabled: true,
                                          landmarksEnabled: true,
                                          excludedPointIdentifiers: nil)
        // Calculate a route and plot on the map with our specified route options
        PWRoute.createRoute(from: startPoi,
                            to: endPoi,
                            options: routeOptions,
                            completion: { [weak self] (route, error) in
                                if error != nil {
                                    logger(error!.localizedDescription)
                                    self?.mapViewController?.mapView.zoomToMapPoint(endPoi)
                                    if error?.localizedDescription == "Invalid end point." || error?.localizedDescription == "Invalid start point." {
                                        self?.dismiss(animated: true)
                                        self?.mapViewController?.zoomToInvalidDestinationPOS(endPoi)
                                    } else {
                                        self?.present(CSAlertHelper.showAlertError(errorMessage: "Invalid route.\nPlease try again."), animated: true)
                                    }
                                    return
                                }
                                guard let strongSelf = self,
                                    let createdRoute = route else {
                                        logger("Route not created")
                                        self?.present(CSAlertHelper.showAlertError(errorMessage: "Invalid route.\nPlease try again."), animated: true)
                                        return
                                }
                                
                                strongSelf.presentRoutingMapView(route: createdRoute, origin: startPoi, destination: endPoi, fromCurrentLocation: fromCurrentLocation)
        })
    }

    internal func presentRoutingMapView(route: PWRoute, origin: PWMapPoint?, destination: PWMapPoint?, fromCurrentLocation: Bool = false) {
        guard let mapRoutingViewController = UIStoryboard(name: String(describing: CSRoutingMapViewController.self), bundle: CSBundleHelper.bundle).instantiateInitialViewController() as? CSRoutingMapViewController,
            let currentMapViewController = mapViewController, let routeInstructions = route.routeInstructions else {
            return
        }

        CSPersistenceHelper.save(route: route, currentLocation: fromCurrentLocation)

        mapRoutingViewController.mapViewController = currentMapViewController
        mapRoutingViewController.mapView = currentMapViewController.mapView
        mapRoutingViewController.routeToDisplay = route
        mapRoutingViewController.routeinstructions = routeInstructions
        mapRoutingViewController.originPOI = origin
        mapRoutingViewController.destinationPOI = destination
        mapRoutingViewController.useCurrentLocation = !(origin is PWPointOfInterest || origin is PWCustomPointOfInterest)
        
        navigationController?.pushViewController(mapRoutingViewController, animated: false)
    }
    
    internal func showSelectedPOIDetail(_ poi: PWMapPoint) {
        guard let poiDetailViewController = UIStoryboard(name: String(describing: CSPointOfInterestDetailViewController.self), bundle: CSBundleHelper.bundle).instantiateInitialViewController() as? CSPointOfInterestDetailViewController else {
            return
        }

        if let poi = poi as? PWPointOfInterest {
            poiDetailViewController.poiToDisplay = poi
            poiDetailViewController.delegate = self
            navigationController?.pushViewController(poiDetailViewController, animated: true)
        } else if let poi = poi as? PWCustomPointOfInterest {
            routeToPointOfInterest(poi)
        }

    }
}

extension CSMapModuleViewController: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOff {
//            let wasDisplayed = isCBCentralManagerPowerAlertShown
//            isCBCentralManagerPowerAlertShown = true
//            if wasDisplayed && isCBCentralManagerPowerAlertShown {
//                promptForBluetoothNotOn()
//            }
//        }
    }
}

extension CSMapModuleViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
}
