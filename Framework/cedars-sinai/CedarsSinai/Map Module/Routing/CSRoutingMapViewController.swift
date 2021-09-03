//
//  CSRoutingMapViewController.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/3/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit
import SDCAlertView
import Kingfisher
import MBProgressHUD

class CSRoutingMapViewController: UIViewController {

    @IBOutlet weak var mapReferenceView: UIView!
    @IBOutlet weak var instructionsCollectionView: UICollectionView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var trackingButton: CSTrackingButton!

    internal var useCurrentLocation = false
    fileprivate let marginConstant = CGFloat(16)
    fileprivate let cellReuseIdentifier = "routeCollectionViewCell"
    fileprivate var notificationCenter: NotificationCenter = NotificationCenter.default
    fileprivate var promptRerouteDisabled = false
    fileprivate var promptArrivalDisabled = false

    fileprivate var rerouteAlert: UIAlertController?
    
    fileprivate var currentShownIndex = 0

    fileprivate var imagePrefetcher: ImagePrefetcher?
    fileprivate var lastUserLocation: PWIndoorLocation?
    

    // TODO: Use a common interface for PWCustomPointOfInterest and PWPointOfInterest
    public var originPOI: PWMapPoint?
    public var destinationPOI: PWMapPoint? {
        didSet {
            guard let destination = destinationPOI as? PWPointOfInterest else {
                return
            }
            prefetchImage(with: destination.metadataImageUrl)
        }
    }

    public var routeinstructions: [PWRouteInstruction]!
    public weak var mapViewController: CSMapViewController!
    public var mapView: PWMapView!
    public var routeToDisplay: PWRoute?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        setUpMapView(mapView)
        setUpNavigationBar()
        setUpCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setCollectionViewShadow()
        mapTrackingMode(to: .followWithHeading)
        
        notificationCenter.addObserver(self, selector: #selector(changeRouteInstruction(notification:)), name: CSNotificationNamesHelper.PWRouteInstructionChanged, object: nil)

        let parameters = [Event.Parameter.screenName.rawValue : "Route Turn by Turn"]
        CSMapModule.sendEvent(Event.Name.screenView.rawValue, paramaters: parameters)
        CSMapModule.startEvent("Route Turn by Turn", parameters: nil)
        logger("Start timed event", data: parameters)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CSMapModule.endEvent("Route Turn by Turn", parameters: nil)
        logger("End timed event")
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }

    // MARK:- Actions
    @IBAction func didTapTrackingButton(_ sender: UIButton) {
        changeMapTrackingState()
    }
    @IBAction func didTapCancelRouteButton(_ sender: UIButton) {
        cancelRouting()
    }
}

// MARK:- View Configuration
extension CSRoutingMapViewController {
    fileprivate func setUpMapView(_ mapView: PWMapView) {
        mapView.delegate = self
        mapView.managedCompassEnabled = true
        mapReferenceView.addSubview(mapView)
        
        mapView.topAnchor.constraint(equalTo: mapReferenceView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: mapReferenceView.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: mapReferenceView.layoutMarginsGuide.leadingAnchor, constant: -marginConstant).isActive = true
        mapView.trailingAnchor.constraint(equalTo: mapReferenceView.layoutMarginsGuide.trailingAnchor, constant: marginConstant).isActive = true
        

        update(mapView: mapView, route: routeToDisplay)
    }

    fileprivate func update(mapView: PWMapView, route: PWRoute?) {
        guard let route = route else {
            return
        }

        let trackingMode = mapView.trackingMode
        routeToDisplay = route
        mapView.navigate(with: route)
        if let routeinstructions = route.routeInstructions,
            let routeInstruction = routeinstructions.first,
            let startMapPoint = routeInstruction.points.first {

            let coordinate = startMapPoint.coordinate
            let heading = routeInstruction.movementTrueHeading
            let distance = 100.0

            let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: distance, pitch: 0, heading: heading)

            mapView.setCamera(camera, animated: true)
            mapView.setRouteManeuver(routeInstruction)
            mapTrackingMode(to: trackingMode)
        }
        instructionsCollectionView.reloadData()
    }
    
    fileprivate func setHeadingToRouteInstruction(mapView: PWMapView, userLocation: PWIndoorLocation?, routeInstruction: PWRouteInstruction)
    {
        if (userLocation != nil)
        {
            let heading = routeInstruction.movementTrueHeading
            let camera = mapView.camera
            camera.heading = heading
            mapView.setCamera(camera, animated: true)
        }
    }

    fileprivate func setUpNavigationBar() {
        let buttonImage = UIImage(named: "icon_back", in: CSBundleHelper.bundle, compatibleWith: nil)
        let dismissNavBarButton = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(dismissView))
        let directionsNavBarButton = UIBarButtonItem(title: "Directions", style: .plain, target: self, action: #selector(showRouteDirections))

        navigationItem.leftBarButtonItem = dismissNavBarButton
        navigationItem.rightBarButtonItem = directionsNavBarButton
    }
    
    fileprivate func setUpCollectionView() {
        instructionsCollectionView.delegate = self
        instructionsCollectionView.dataSource = self
        instructionsCollectionView.register(UINib(nibName: String(describing: CSRouteDirectionCollectionViewCell.self), bundle: CSBundleHelper.bundle), forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    fileprivate func setCollectionViewShadow() {
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        shadowView.layer.shadowRadius = 2
        
        shadowView.layer.shadowPath = UIBezierPath(rect: instructionsCollectionView.bounds).cgPath
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    @objc fileprivate func dismissView() {
        mapView.removeFromSuperview()
        mapView.delegate = mapViewController
        mapViewController.resetMapView()

        exitFromModule()
    }

    fileprivate func cancelRouting() {
        mapView.delegate = mapViewController
        CSPersistenceHelper.clearRoute()
        mapView.removeFromSuperview()
        mapViewController.resetMapView()
        navigationController?.popViewController(animated: false)
    }

    fileprivate func exitFromModule () {
        let viewControllersCount = navigationController?.viewControllers.count ?? 0
        if viewControllersCount > 2 {
            let viewControllerIndex = viewControllersCount - 3
            let viewControllerToPop = navigationController?.viewControllers[viewControllerIndex]
            navigationController?.popToViewController(viewControllerToPop!, animated: true)
        }

    }
    
    @objc fileprivate func showRouteDirections() {
        guard let routeDirectionsListViewController = UIStoryboard(name: String(describing: CSRoutingDirectionsListViewController.self), bundle: CSBundleHelper.bundle).instantiateInitialViewController() as? CSRoutingDirectionsListViewController, let routeInstructions = routeToDisplay?.routeInstructions else {
            return
        }

        routeDirectionsListViewController.routeDirections = routeInstructions
        routeDirectionsListViewController.originPOI = originPOI
        routeDirectionsListViewController.destinationPOI = destinationPOI
        routeDirectionsListViewController.building = mapView.building
        
        navigationController?.present(routeDirectionsListViewController, animated: true)
    }

    fileprivate func updateInstructionsLocation(_ userLocation: PWUserLocation) {

        instructionsCollectionView.visibleCells.forEach { (cell) in
            guard let cell = cell as? CSRouteDirectionCollectionViewCell else {
                return
            }

            updateCell(cell, location: userLocation.location)
        }
    }

    fileprivate func updateCell(_ cell: CSRouteDirectionCollectionViewCell, location: CLLocation) {
        let instruction = cell.routeInstruction!
        switch instruction.movementDirection {
        case .straight, .left, .bearLeft, .right, .bearRight:
            break
        default:
            return
        }

        let instructionLocation = locationFor(instruction)
        let distance = instructionLocation.distance(from: location)
        cell.mainInstructionLabel.text = instruction.movement(with: distance)
    }

    fileprivate func locationFor(_ instruction: PWRouteInstruction) -> CLLocation {
        let lastPoint = instruction.points.last as! PWMapPoint
        return lastPoint.location
    }

    fileprivate func prefetchImage(with url: URL?) {
        guard let url = url else {
            return
        }
        imagePrefetcher = ImagePrefetcher(urls: [url])
        imagePrefetcher?.start()
    }
}

// MARK:- Alerts
extension CSRoutingMapViewController {
    fileprivate func showEndOfRouteAlert() {
        let alert = AlertController(title: "Destination",
                                    message: "You have arrived at your destination", preferredStyle: .alert)

        let okAction = AlertAction(title: "End Route", style: .preferred) { [weak self] (action) in
            self?.cancelRouting()
        }

        let cancelAction = AlertAction(title: "Dismiss", style: .normal)

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        if let destinationPOI = destinationPOI as? PWPointOfInterest {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            alert.contentView.addSubview(imageView)
            let views = ["imageView": imageView]
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView(<=200)]|", options: .alignAllLeading, metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView(<=270)]|", options: .alignAllCenterX, metrics: nil, views: views)
            NSLayoutConstraint.activate(constraints)
            imageView.contentMode = .scaleAspectFit
            
            imageView.kf.setImage(with: destinationPOI.metadataImageUrl) { [weak self] (_, _, _, _) in
                self?.present(alert, animated: true)
            }
        } else {
    		present(alert, animated: true)
        }
    }

    fileprivate func showRerouteAlert(with currentLocation: PWUserLocation) {
        if promptRerouteDisabled {
            return
        } else {
            promptRerouteDisabled = true
        }
        let alert = UIAlertController(title: "You have left the route", message: "", preferredStyle: .alert)

        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissAction)

        let rerouteAction = UIAlertAction(title: "Reroute Me", style: .default, handler: { [weak self] (action) in
            guard let strongSelf = self,
                let destination = strongSelf.destinationPOI else {
                    return
            }

            strongSelf.rerouteFrom(location: currentLocation, to: destination)
        })
        alert.addAction(rerouteAction)

        rerouteAlert = alert

        present(alert, animated: true)
    }
}


// MARK:- Location Updates
extension CSRoutingMapViewController {

    fileprivate func computeMinDistance(_ location: PWUserLocation, instruction: PWRouteInstruction) -> Double
    {
        let userLocation = location.location
        var minDistance = CLLocationDistance(Double.greatestFiniteMagnitude)

        for i in stride(from: 0, to: (instruction.points.count - 1), by: 1) {
            let pointA = instruction.points[i]
            let pointB = instruction.points[i+1]
            
            let distance = userLocation.distanceFromLineWithPoints(from: pointA.location, to: pointB.location)
            minDistance = min(distance, minDistance)
            if distance < CSMapModule.alertDistance {
                break
            }
        }
        return minDistance;
    }
    
    // We should only need to check currentRouteInstuction.  However, there seems to be a bug in Mapkit SDK,
    // where the currentRouteInstuction doesn't follow userLocation.  We now need to check all instructions just in case.
    fileprivate func checkRouteDistance(_ location: PWUserLocation) {

        var minDistance = CLLocationDistance(Double.greatestFiniteMagnitude)
        
        minDistance = computeMinDistance(location, instruction: mapView.currentRouteInstruction())
        if (minDistance >= CSMapModule.alertDistance) {
            for instruction in routeinstructions {
                minDistance = computeMinDistance(location, instruction: instruction)
                if (minDistance < CSMapModule.alertDistance) {
                    break;
                }
            }
        }

//        if minDistance > CSMapModule.rerouteDistance {
//
//            rerouteAlert?.dismiss(animated: true, completion: nil)
//            promptRerouteDisabled = false
//            rerouteAlert = nil
//
//            if let destination = destinationPOI {
//                rerouteFrom(location: location, to: destination)
//            }
//        } else
        if minDistance > CSMapModule.alertDistance && !mapView.currentRouteInstruction().isOnFloorChange() {
            showRerouteAlert(with: location)
        } else {
            // User is in route again, re-enable the prompt
            promptRerouteDisabled = false
        }
    }

    fileprivate func rerouteFrom(location: PWMapPoint, to destination: PWMapPoint) {
        // User is in route again, re-enable the prompt
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Rerouting..."

        let routeOptions = PWRouteOptions(accessibilityEnabled: true,
                                          landmarksEnabled: true,
                                          excludedPointIdentifiers: nil)
        // Calculate a route and plot on the map with our specified route options
        PWRoute.createRoute(from: location,
                            to: destination,
                            options: routeOptions,
                            completion: { [weak self] (route, error) in
                                DispatchQueue.main.async {
                                    hud.hide(animated: true)
                                }
                                if error != nil {
                                    logger("Reroute error: \(error!.localizedDescription)")
                                    
                                    // prevent the route from being set and screw instructions
                                    return
                                }
                                
                                guard let strongSelf = self,
                                    let route = route else {
                                        return
                                }
                                
                                strongSelf.promptRerouteDisabled = false
                                strongSelf.originPOI = location
                                strongSelf.destinationPOI = destination
                                strongSelf.update(mapView: strongSelf.mapView, route: route)
        })
    }
    
}

// MARK:- Tracking button
extension CSRoutingMapViewController {

    fileprivate func changeMapTrackingState() {
        let newTrackingMode = CSMapTrackingModeHelper.getMapViewTrackingState(currentState: mapView.trackingMode)

        // Manually chanigng the tracking mode instead of using the delegate
        // let us reset to a previous state after leaving routing
        mapTrackingMode(to: newTrackingMode)
    }

    // For FollowMeWithHeading tracking mode when route is enabled,
    // just set Mapview tracking mode to follow, because we'll be setting the heading.
    fileprivate func mapTrackingMode(to trackingMode: PWTrackingMode) {
        trackingButton.mapTrackingMode = trackingMode
        mapView.trackingMode = trackingMode
    }

}

// MARK:- Notification Methods
extension CSRoutingMapViewController {
    @objc fileprivate func changeRouteInstruction(notification: Notification) {
        guard let routeInstruction = notification.object as? PWRouteInstruction, let routeInstructions = routeToDisplay?.routeInstructions, routeInstruction != routeInstructions[currentShownIndex]  else {
            return
        }
        if let index = routeInstructions.firstIndex(of: routeInstruction) {
            let indexPath = IndexPath(row: index, section: 0)
            let scrollPosition: UICollectionView.ScrollPosition = index > currentShownIndex ? .left : .right
            
            instructionsCollectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: true)
        }
    }
}

// MARK:- UIScrollViewDelegate
extension CSRoutingMapViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = instructionsCollectionView.contentOffset.x / instructionsCollectionView.frame.size.width
        currentShownIndex = Int(currentIndex)
        mapView.setRouteManeuver(routeinstructions[currentShownIndex])
    }
}

// MARK:- UICollectionViewDataSource
extension CSRoutingMapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return routeToDisplay?.routeInstructions.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let routeCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? CSRouteDirectionCollectionViewCell,
            let instrucitonsArray = routeToDisplay?.routeInstructions else {
            return UICollectionViewCell()
        }
        let instructionToDisplay = instrucitonsArray[indexPath.row]

        routeCell.routeInstruction = instructionToDisplay

        return routeCell
    }
}

// MARK:- UICollectionViewDelegateFlowLayout
extension CSRoutingMapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return instructionsCollectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension CSRoutingMapViewController: PWMapViewDelegate {
    func mapView(_ mapView: PWMapView, locationManager: PWLocationManager, didUpdateIndoorUserLocation userLocation: PWUserLocation) {

        if mapView.currentRoute != nil {
            let distanceThreshold = CLLocationDistance(4)
            if let endPOI = mapView.currentRoute.endPoint {
//                let distanceToEndPOI = endPOI.location.distance(from: CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude))
                let distanceToEndPOI = endPOI.location.distance(from: userLocation.location)
                if distanceToEndPOI < distanceThreshold && !promptArrivalDisabled && endPOI.floorID == userLocation.floorID  {
                    promptArrivalDisabled = true
                    showEndOfRouteAlert()
                }
            }
        }
        
        self.lastUserLocation = userLocation

//        guard let userLocation = userLocation as? PWUserLocation else {
//            return
//        }
        updateInstructionsLocation(userLocation)
        if useCurrentLocation {
            checkRouteDistance(userLocation)
        }
    }
}
