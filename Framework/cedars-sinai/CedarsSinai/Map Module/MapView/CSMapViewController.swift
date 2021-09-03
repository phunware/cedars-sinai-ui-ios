//
//  CSMapViewController.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/18/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit
import PWLocation
import PWEngagement

class CSMapViewController: UIViewController {
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var addPinButton: UIButton!
    @IBOutlet weak var trackingButton: CSTrackingButton!
    @IBOutlet weak var searchTextField: CSSearchTextField! {
        didSet {
            searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    @IBOutlet var searchFieldDelegate: CSTextFieldHandler! {
        didSet {
            searchFieldDelegate.textFieldShouldBeginAction = {[weak self] _ in
                self?.notificationCenter.post(name: CSNotificationNamesHelper.mapSearchTapped, object: nil)
                return false
            }

            searchFieldDelegate.textFieldDidBeginAction = { [weak self] _ in
                if self?.searchTextField.text == "" {
                    self?.userIsSearching = false
                    self?.filterMapViewPOIsByType()
                } else {
                    self?.userIsSearching = true
                    if let searchTerm = self?.searchTextField.text {
                        self?.filterMapViewPOIsBySearch(searchTerm: searchTerm)
                    }
                }
            }
            searchFieldDelegate.textFieldClearAction = { [weak self] _ in
                self?.userIsSearching = false
                self?.filterMapViewPOIsByType()
            }
        }
    }
    
    let mapView: PWMapView = PWMapView(frame: .zero)

    var parkingAnnotation: PWMapPoint?
    var defaultMapViewRect: MKMapRect?

    var currentLocation: PWUserLocation? {
        return mapView.indoorUserLocation
    }
    
    private let seguesIdentifiers = (poiFilter: "poiFilterSegue", floorSelector: "floorSelectorSegue")
    private let marginConstant = CGFloat(16)
    
    private var userIsSearching = false
    private var firstLocationAcquired = false
    private var currentTrackingState: PWTrackingMode = .none
    private var currentPOITypeFilter: PWPointOfInterestType?
    private var filteredPOIs: [PWPointOfInterest] = []
    private var allBuildingPOITypes: [PWPointOfInterestType]? {
        return currentBuilding.allCurrentPointOfInterestType()
    }
    
    weak var containerViewController: CSMapModuleViewController!

    var currentBuilding = PWBuilding() {
        didSet {
            mapView.setBuilding(currentBuilding, animated: true, onCompletion: nil)
            setUpMapView()
        }
    }
    var currentFloorPOIs: [PWPointOfInterest]? {
        return mapView.currentFloor.pointsOfInterest
    }

    private var locationManager: PWLocationManager?

    lazy var notificationCenter: NotificationCenter = .default
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setUpViewShadow()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationCenter.addObserver(self, selector: #selector(routeFromNotification(notification:)),
                                       name: CSNotificationNamesHelper.startNavigatingRoute, object: nil)
        notificationCenter.addObserver(self, selector: #selector(notifyShowRoute(notification:)),
                                       name: CSNotificationNamesHelper.plotRoute, object: nil)

        let parameters = [Event.Parameter.screenName.rawValue : "Map"]
        CSMapModule.sendEvent(Event.Name.screenView.rawValue, paramaters: parameters)
        CSMapModule.startEvent("Map", parameters: nil)
        logger("Start timed event", data: parameters)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CSMapModule.endEvent("Map", parameters: nil)
        logger("End timed event")
    }
    
    deinit {
        notificationCenter.removeObserver(self)
        mapView.trackingMode = .none
        mapView.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == seguesIdentifiers.poiFilter {
            if let poiTypeFilterViewController = segue.destination as? CSDirectoryFilterViewController,
                let buildingPOITypes = allBuildingPOITypes,
                let poiTypeImagesArray = currentBuilding.getPointOfInterestTypeImages() {
                poiTypeFilterViewController.pointOfInterestTypes = buildingPOITypes
                poiTypeFilterViewController.poiTypeImageModelArray = poiTypeImagesArray
                poiTypeFilterViewController.currentSelectedFilter = currentPOITypeFilter
                poiTypeFilterViewController.delegate = self
            }
        } else if segue.identifier == seguesIdentifiers.floorSelector {
            if let floorSelectorViewController = segue.destination as? CSFloorSelectorViewController {
                floorButtonSegue(with: floorSelectorViewController)
            }
        }
    }


    // MARK: - Segue Actions

    func floorButtonSegue(with destinationViewController: CSFloorSelectorViewController) {
        guard let floors = currentBuilding.floors as? [PWFloor] else {
            return
        }
        destinationViewController.floors = floors
        destinationViewController.currentFloor = mapView.currentFloor
        destinationViewController.delegate = self
    }
    
    //MARK: - Button Actions
    @IBAction func addPinAction(_ sender: UIButton) {
        handlePinAction()
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Add/Remove Pin"])
    }
    
    @IBAction func showRoutingView(_ sender: UIButton) {
        presentRoutingView(destinationPOI: nil)
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Show Routing View"])
    }
    
    @IBAction func changeMapTrackingMode(_ sender: CSTrackingButton) {
        changeMapTrackingState()
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Change Tracking Mode"])
    }
}

//MARK: - Public Methods
extension CSMapViewController {
    public func configureMapViewFrame() {
        mapViewContainer.addSubview(mapView)

        mapView.topAnchor.constraint(equalTo: mapViewContainer.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: mapViewContainer.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: mapViewContainer.layoutMarginsGuide.leadingAnchor, constant: -marginConstant).isActive = true
        mapView.trailingAnchor.constraint(equalTo: mapViewContainer.layoutMarginsGuide.trailingAnchor, constant: marginConstant).isActive = true
    }
    
    public func resetMapView() {
        mapView.cancelRouting()

        configureMapViewFrame()
        resumeMapState()
    }
}

//MARK: - View Configuration
extension CSMapViewController {
    private func setUpMapView() {
        mapView.delegate = self
        mapView.managedCompassEnabled = true
        mapView.setBuilding(currentBuilding, animated: true, onCompletion: {(error) in
            if error != nil {
                logger("error setting building")
                logger("\(error!.localizedDescription)")
            }
        })
        
        locationManager = PWManagedLocationManager(buildingId: currentBuilding.identifier)
        mapView.register(locationManager)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        configureMapViewFrame()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapViewWasTapped(_:)))
        tapGestureRecognizer.delegate = self
        
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUpViewShadow() {
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 5.5)
        shadowView.layer.shadowRadius = 4
        
        let shadowViewFrame = shadowView.frame
        let shadowRect = CGRect(x: shadowViewFrame.origin.x, y: shadowViewFrame.origin.y, width: shadowViewFrame.width, height: shadowViewFrame.height - 5.5)
        shadowView.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = 1
    }
    
    private func filterMapViewPOIsBySearch(searchTerm: String) {
        guard var foundFloorPOIs = mapView.currentFloor.pointsOfInterest else {
            return
        }
        foundFloorPOIs = foundFloorPOIs.filter {
            guard let poiTitle = $0.title else {
                return false
            }
            return poiTitle.localizedCaseInsensitiveContains(searchTerm)
        }
        if let poiTypeFilter = currentPOITypeFilter {
            foundFloorPOIs = foundFloorPOIs.filter { $0.pointOfInterestType == poiTypeFilter }
        }
        filteredPOIs = foundFloorPOIs
        highlightFilteredPOIs()
    }
    
    private func filterMapViewPOIsByType() {
        if let selectedPOITypeFilter = currentPOITypeFilter, let currentFloorPOIs = mapView.currentFloor.pointsOfInterest {
            var filteredPOIsByType = currentFloorPOIs.filter { $0.pointOfInterestType == selectedPOITypeFilter }
            if userIsSearching {
                filteredPOIsByType = filteredPOIsByType.filter { $0.title!.localizedCaseInsensitiveContains(searchTextField.text!) }
            }
            filteredPOIs = filteredPOIsByType
            highlightFilteredPOIs()
        } else {
            redrawMapViewPOIs()
        }
    }
    
    private func redrawMapViewPOIs() {
        guard let currentFloorPOIs = mapView.currentFloor.pointsOfInterest else {
            return
        }
        for poi in currentFloorPOIs {
            if let poiView = mapView.view(for: poi) {
                poiView.isHidden = false
            }
        }
    }
    
    private func redrawMapViewPOIsWithCondition() {
        if userIsSearching {
            filterMapViewPOIsBySearch(searchTerm: searchTextField.text!)
        } else {
            filterMapViewPOIsByType()
        }
    }
    
    private func resumeMapState() {
        mapView.trackingMode = currentTrackingState
        trackingButton.mapTrackingMode = currentTrackingState

        redrawMapViewPOIsWithCondition()
    }
    
    private func highlightFilteredPOIs() {
        guard var allFloorPOIs = currentFloorPOIs else {
            return
        }
        for poi in filteredPOIs {
            if let index = allFloorPOIs.firstIndex(of: poi), let poiView = mapView.view(for: poi) {
                allFloorPOIs.remove(at: index)
                poiView.isHidden = false
            }
        }
        for poi in allFloorPOIs {
            if let poiView = mapView.view(for: poi) {
                poiView.isHidden = true
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        userIsSearching = searchTextField.text! != ""
        
        redrawMapViewPOIsWithCondition()
    }
    
    @objc private func mapViewWasTapped(_ gestureReconizer: UIGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }
}

//MARK: - Toolbar Actions
extension CSMapViewController {
    private func handlePinAction() {
        if let parking = parkingAnnotation {
            parkingPOISelectedAlert(with: parking)
        } else {
            //add
            addParkingPOI(in: mapView)
        }
    }
    
    private func changeMapTrackingState() {
        let newTrackingMode = CSMapTrackingModeHelper.getMapViewTrackingState(currentState: mapView.trackingMode)

        // Manually chanigng the tracking mode instead of using the delegate
        // let us reset to a previous state after leaving routing
        mapTrackingMode(to: newTrackingMode)
    }

    private func mapTrackingMode(to trackingMode: PWTrackingMode) {
        mapView.trackingMode = trackingMode
        currentTrackingState = trackingMode
        trackingButton.mapTrackingMode = trackingMode
    }
    
    internal func presentRoutingView(destinationPOI: PWMapPoint?) {
        guard let routingViewController = UIStoryboard(name: String(describing: CSRouteViewController.self), bundle: CSBundleHelper.bundle).instantiateInitialViewController() as? CSRouteViewController, var allBuildingPOIs: [PWMapPoint] = currentBuilding.allPointOfinterest() else {
            return
        }

        if let parkingPOI = parkingAnnotation as? PWCustomPointOfInterest {
            allBuildingPOIs.append(parkingPOI)
        }
        routingViewController.delegate = self
        routingViewController.destinationPoint = destinationPOI
        routingViewController.poiArray = allBuildingPOIs

        // This triggers home to venue display H2V
        // CSMC-14 is beign removed
//        routingViewController.showRoutingPrompt = !CSMapModule.userIsInsideZones()
        routingViewController.moduleViewController = self

        show(routingViewController, sender: nil)
    }

    private func checkParkingPOINeeded(userLocation: PWUserLocation?, building: PWBuilding) {
        guard let location = userLocation?.location else {
            return
        }
        let nearBuilding = building.close(to: location)
        if parkingAnnotation != nil && !nearBuilding {
            deleteParkingPOIAlert()
        }
    }
}

//MARK: - Public Method
extension CSMapViewController {
    public func routeToPointOfInterest(_ poi: PWMapPoint) {
        presentRoutingView(destinationPOI: poi)
    }
    
    public func zoomToInvalidDestinationPOS(_ poi: PWMapPoint) {
        self.present(CSAlertHelper.showAlertError(errorMessage: "There is no turn-by-turn navigation available for this location. Press OK to find it on the map."), animated: true)
        self.mapView.zoomToMapPoint(poi)
    }
}

//MARK: - SelectBuildingFloor Delegate
extension CSMapViewController: SelectBuildingFloorDelegate {
    func didSelectFloor(_ floor: PWFloor) {
        if floor.floorID != mapView.currentFloor.floorID {
            mapView.currentFloor = floor
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: { //Give time so the mapview sets the floor
                self.redrawMapViewPOIs()
                self.resumeMapState()

                // CSMC-295: Disable tracking after changing floor
                self.mapTrackingMode(to: .none)
            })
        }
    }
}

//MARK: - Filter Delegate
extension CSMapViewController: PointOfInterestTypeFilterDelegate {
    func selectedFilter(_ poiType: PWPointOfInterestType?) {
        currentPOITypeFilter = poiType
        
        redrawMapViewPOIsWithCondition()
    }
}

//MARK: - Routing
extension CSMapViewController: RoutingViewControllerDelegate {
    func routeToDisplay(_ route: PWRoute) {
        routeToDisplay(route, origin: nil, destination: nil, fromCurrentLocation: false)
    }

    func routeToDisplay(_ route: PWRoute, origin: PWMapPoint?, destination: PWMapPoint?, fromCurrentLocation: Bool) {
        redrawMapViewPOIs()
        containerViewController.presentRoutingMapView(route: route, origin: origin, destination: destination, fromCurrentLocation: fromCurrentLocation)
    }
    
    func routeToVenue(destinationPoint: PWMapPoint?) {
        let mapPlacemark: MKPlacemark
        if let destinationLocation = destinationPoint {
            mapPlacemark = MKPlacemark(coordinate: destinationLocation.coordinate, addressDictionary: nil)
        } else {
            mapPlacemark = MKPlacemark(coordinate: currentBuilding.coordinate, addressDictionary: nil)
        }
        let mapItem = MKMapItem(placemark: mapPlacemark)
        if let destinationTitle = destinationPoint?.title as? String {
            mapItem.name = destinationTitle == mapView.userLocation.title ? "Custom Location" : destinationTitle + " at " + currentBuilding.name
        } else {
            mapItem.name = currentBuilding.name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    @objc private func routeFromNotification(notification: Notification) {
        if let route = notification.object as? PWRoute {
            routeToDisplay(route)
        }
    }
    
    @objc private func notifyShowRoute(notification: NSNotification) {
        guard let route: PWRoute = notification.object as? PWRoute else {
            return
        }
        routeToDisplay(route)
    }
}

// MARK:- UIGestureRecognizerDelegate
extension CSMapViewController: UIGestureRecognizerDelegate {
    
}

//MARK: - Parking POI
extension CSMapViewController {
    func loadParkingPOI() {
        guard let (location, floorId, buildingId) = CSPersistenceHelper.location() else {
                return
        }

        let poi = parkingPOI(in: location, floorId: floorId, buildingId: buildingId)

        addParkingPOI(poi, map: mapView)
    }

    func addParkingPOI(_ parkingPoi: PWCustomPointOfInterest, map: PWMapView) {
        parkingAnnotation = parkingPoi
        mapView.addAnnotation(parkingPoi)

        let parkingImage = UIImage(named: "ios_icon_pin_on", in: CSBundleHelper.bundle, compatibleWith: nil)
        addPinButton.setImage(parkingImage, for: .normal)

        notificationCenter.post(name: Notification.Name.UserDidAddParkingPOI, object: parkingPoi)
        CSPersistenceHelper.saveLocation(parkingPoi.coordinate, floorId: parkingPoi.floorID, buildingId: parkingPoi.buildingID)
    }

    func addParkingPOI(in mapView: PWMapView, coordinates: CLLocationCoordinate2D? = nil) {
        let currentFloor = mapView.currentFloor!
        let coordinates = coordinates ?? mapView.centerCoordinate
        let parkingPoi = parkingPOI(in: coordinates, floor: currentFloor)
        addParkingPOI(parkingPoi, map: mapView)
        addParkingPOIAlert()
    }

    func removeParkingPOI() {
        guard let annotation = parkingAnnotation else {
            return
        }
        mapView.removeAnnotation(annotation)
        CSPersistenceHelper.clearSavedLocation()

        let parkingImage = UIImage(named: "ios_icon_pin", in: CSBundleHelper.bundle, compatibleWith: nil)
        addPinButton.setImage(parkingImage, for: .normal)
        parkingAnnotation = nil
        notificationCenter.post(name: Notification.Name.UserDidRemoveParkingPOI, object: nil)
    }

    func parkingPOI(in coordinates: CLLocationCoordinate2D, floor: PWFloor) -> PWCustomPointOfInterest {
        return parkingPOI(in: coordinates, floorId: floor.floorID, buildingId: floor.building.identifier)
    }

    func parkingPOI(in coordinates: CLLocationCoordinate2D, floorId: Int, buildingId: Int) -> PWCustomPointOfInterest {
        let poiImage = UIImage(named: "parking_poi", in: CSBundleHelper.bundle, compatibleWith: nil)
        let poi = PWCustomPointOfInterest(coordinate: coordinates, floorId: floorId, buildingId: buildingId, title: "My Parking Spot", image: poiImage)!
        poi.identifier = CSMapModule.ParkingPOIIdentifier
        poi.isShowTextLabel = true
        return poi
    }

    func addParkingPOIAlert() {
        let alert = UIAlertController(title: "My Parking Spot", message: "This will mark your parking spot on the map. Search for \"My Parking Spot\" or select the parking icon from the toolbar when you want to route back to your vehicle.", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] (action) in
            self?.removeParkingPOI()
        }
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    func parkingPOISelectedAlert(with poi: PWMapPoint) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let routeAction = UIAlertAction(title: "Route to My Parking Spot", style: .default) { [weak self] (action) in
            self?.presentRoutingView(destinationPOI: poi)
        }
        alert.addAction(routeAction)

        let deleteAction = UIAlertAction(title: "Delete Pin", style: .destructive) { [weak self] (action) in
            self?.removeParkingPOI()
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    func deleteParkingPOIAlert () {
        let alert = UIAlertController(title: "Delete My Parking Spot",
                                      message: "Looks like you don't need to save your parking spot anymore",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (action) in
            self?.removeParkingPOI()
        }
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }

}

//MARK: - PWMapView Delegate
extension CSMapViewController: PWMapViewDelegate {

    func mapView(_ mapView: PWMapView!, didFinishLoading building: PWBuilding!) {

        if parkingAnnotation == nil {
            loadParkingPOI()
            checkParkingPOINeeded(userLocation: mapView.indoorUserLocation, building: mapView.building)
        }

        logger("mapview did finish loading map")
        if !CSPersistenceHelper.routeFromCurrentLocation() {
            containerViewController.presentRoutingMapView(building)
        }
        defaultMapViewRect = mapView?.visibleMapRect
    }

    func mapView(_ mapView: PWMapView!, didAnnotateView view: PWBuildingAnnotationView!, with poi: PWPointOfInterest!) {
        if let currentFilter = currentPOITypeFilter {
            if let _ = poi as? PWCustomPointOfInterest {
                view.isHidden = false
            } else {
                view.isHidden = !(poi.pointOfInterestType.identifier == currentFilter.identifier)
            }
        } else {
            view.isHidden = false
        }
    }

    func mapViewWillSetInitialFloor(_ mapView: PWMapView!) -> PWFloor? {
        return mapView.building.initialFloor
    }

    func mapView(_ mapView: PWMapView!, didSelect view: PWBuildingAnnotationView!, with poi: PWPointOfInterest!) {
        if mapView.currentRoute == nil {

            mapView.deselectAnnotation(poi, animated: false)

            if let annotation = parkingAnnotation as? PWCustomPointOfInterest,
                poi.identifier == annotation.identifier {
                parkingPOISelectedAlert(with: poi)
            } else {
                presentRoutingView(destinationPOI: poi)
            }
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)

        if let annotation = parkingAnnotation as? PWCustomPointOfInterest,
            let poi = view.annotation as? PWCustomPointOfInterest,
            poi.identifier == annotation.identifier {
            parkingPOISelectedAlert(with: poi)
        }
    }

    func mapViewWillStartLocatingIndoorUser(_ mapView: PWMapView!) {
        mapTrackingMode(to: .followWithHeading)
    }
    
    func mapView(_ mapView: PWMapView!, locationManager: PWLocationManager!, didUpdateIndoorUserLocation userLocation: PWUserLocation!) {
        if !firstLocationAcquired {
            firstLocationAcquired = true
            mapView.trackingMode = .follow
            if (mapView.currentFloor.floorID != userLocation.floorID) {
                mapView.currentFloor = currentBuilding.floor(byId: userLocation.floorID)
            }
            let camera = MKMapCamera(lookingAtCenter: userLocation.coordinate, fromEyeCoordinate: userLocation.coordinate, eyeAltitude: 1)
            mapView.setCamera(camera, animated: true)
            notificationCenter.post(name: .FirstLocationAcquired, object: nil)
//            trackingButton.isEnabled = true
        }

        if CSPersistenceHelper.routeFromCurrentLocation() {
            logger("Route from current location", data: ["userLocation": userLocation])
            containerViewController.presentRoutingMapView(mapView.building)
        }
    }
}
