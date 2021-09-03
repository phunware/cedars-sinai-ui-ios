//
//  CSRouteViewController.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/27/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit
import Kingfisher
import MBProgressHUD

protocol RoutingViewControllerDelegate: class {
    func routeToDisplay(_ route: PWRoute)
    func routeToDisplay(_ route: PWRoute, origin: PWMapPoint?, destination: PWMapPoint?, fromCurrentLocation: Bool)
    func routeToVenue(destinationPoint: PWMapPoint?)
}

class CSRouteViewController: CSBaseModalViewController {
    
    @IBOutlet weak var mainDirectionsLabel: UILabel!
    @IBOutlet weak var noticedLabel: UILabel!
    @IBOutlet weak var dismissButton: CSCustomButton!
    @IBOutlet weak var mapsButton: CSCustomButton!
    @IBOutlet weak var routeButton: CSCustomButton!
    @IBOutlet weak var directionsToVenueView: UIView!
    @IBOutlet weak var referenceHeightView: UIView!
    @IBOutlet weak var startPoinTextField: CSRouteTextField!
    @IBOutlet weak var endPointTextField: CSRouteTextField!
    @IBOutlet weak var poiTableView: UITableView!
    @IBOutlet weak var directionsToVenueViewHeight: NSLayoutConstraint!
    @IBOutlet var textFieldsDelegate: CSTextFieldHandler! {
        didSet {
            textFieldsDelegate.textFieldDidBeginAction = { [weak self] textField in
                if !(textField.text!.count > 0){
                    self?.userIsSearching = false
                    self?.poiTableView.reloadData()
                }
                self?.lastEditedTextFieldTag = textField.tag
                self?.searchPOIs(searchTerm: textField.text!)
            }
            textFieldsDelegate.textFieldClearAction = { [weak self] tag in
                self?.userIsSearching = false
                self?.poiTableView.reloadData()
                self?.clearSelections(textFieldTag: tag)
            }

            textFieldsDelegate.textFieldShouldReturn = { [weak self] textfield in
                guard let strongSelf = self else { return }
                if strongSelf.endPointTextField == textfield && strongSelf.valideRoutePOIs() {
                    self?.validateRoutePOIs()
                    CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Keyboard Go"])
                }
            }
        }
    }
    
    fileprivate let sectionHeaderViewCellIdentifier = "headerCell"
    fileprivate let poiListCellReuseIdentifier = "directoryCell"
    fileprivate let estimatedCellHeight = CGFloat(80)
    fileprivate let sectionHeaderHeight = CGFloat(30)
    
    fileprivate var lastEditedTextFieldTag = 1 //Default is the route start textfield
    fileprivate var lastEditedTextField: CSRouteTextField? {
        return view.viewWithTag(lastEditedTextFieldTag) as? CSRouteTextField
    }
    fileprivate var userIsSearching = false
    fileprivate var userLocation: PWMapPoint?
    fileprivate var tableViewSections: [String] = []
    fileprivate var sortedPointOfInterests: [CSDirectorySectionModel] = []
    fileprivate var sectionsSearchResults: [String] = []
    fileprivate var pointOfInterestsSearchResults: [CSDirectorySectionModel] = []

    fileprivate let notificationCenter = NotificationCenter.default
    
    public var poiArray: [PWMapPoint]!
    public var showRoutingPrompt = false
    public var filteredPOIArray: [PWMapPoint] = []
    public var startPoint: PWMapPoint?
    public var destinationPoint: PWMapPoint?
    public weak var delegate: RoutingViewControllerDelegate?
    public weak var moduleViewController: CSMapViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        setUpBuildingPOIsList()
        setUpView()
        setUpTableView()
        loadCurrentUserLocationIfAvailable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let parameters = [Event.Parameter.screenName.rawValue : "Route Build"]
        CSMapModule.sendEvent(Event.Name.screenView.rawValue, paramaters: parameters)
        CSMapModule.startEvent("Route Build", parameters: nil)
        logger("Start timed event", data: parameters)
        checkUserDistance()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        routeButton.layoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CSMapModule.endEvent("Route Build", parameters: nil)
        logger("End timed event")
        
        notificationCenter.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: Actions
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true)
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Dismiss Route View"])
    }

    @IBAction func dismissDirectionsView(_ sender: Any) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.directionsToVenueViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }) { completed in
            if completed {
                self.shouldHideDirectionView(true)
            }
        }
    }
    
    @IBAction func invertRoutes(_ sender: UIButton) {
        let temporaryPOI = startPoint
        startPoint = destinationPoint
        destinationPoint = temporaryPOI
        if let startTitle = startPoint?.title {
            startPoinTextField.text = startTitle
        } else {
            startPoinTextField.text = ""
        }
        if let destinationTitle = destinationPoint?.title {
            endPointTextField.text = destinationTitle
        } else {
            endPointTextField.text = ""
        }
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Invert Route"])
    }
    
    @IBAction func routeSelectedPOIs(_ sender: UIButton) {
        validateRoutePOIs()
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Route"])
    }
    
    @IBAction func getUserLocation(_ sender: UIButton) {
        if CSLocationStatusHelper.locationServicesAvailable() {
            getCurrentUserLocation()
        } else {
            present(CSAlertHelper.showAlertError(errorMessage: "Please enable the location services to determine your start position."), animated: true)
        }

        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Route"])
    }
    
    @IBAction func openBuildingLocationInMap(_ sender: CSCustomButton) {
        delegate?.routeToVenue(destinationPoint: destinationPoint)
        dismiss(animated: true)

        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Route"])
    }
}

//MARK: - View Configuration
extension CSRouteViewController {
    fileprivate func setUpBuildingPOIsList() {
        let tableViewContents = CSPointOfInterestsHelper.poiListSections(poiArray)
        tableViewSections = tableViewContents.sectionTitles
        sortedPointOfInterests = tableViewContents.sections
    }
    
    fileprivate func setUpView() {
        notificationCenter.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        startPoinTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        endPointTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if let endPOI = destinationPoint, let title = endPOI.title {
            endPointTextField.text = title
        }
    }
    
    fileprivate func setUpTableView() {
        poiTableView.register(UINib(nibName: String(describing: CSPOIListTableViewCell.self), bundle: CSBundleHelper.bundle), forCellReuseIdentifier: poiListCellReuseIdentifier)
        poiTableView.register(UINib(nibName: String(describing: CSTableSectionHeaderViewCell.self), bundle: CSBundleHelper.bundle), forCellReuseIdentifier: sectionHeaderViewCellIdentifier)
        poiTableView.dataSource = self
        poiTableView.delegate = self
        poiTableView.tableFooterView = UIView() //To prevent showing empty cells
        poiTableView.rowHeight = UITableView.automaticDimension
        poiTableView.estimatedRowHeight = estimatedCellHeight
        poiTableView.keyboardDismissMode = .interactive
    }
    
    fileprivate func checkUserDistance() {
        if showRoutingPrompt {
            shouldHideDirectionView(false)
            
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5) {
                self.directionsToVenueViewHeight.constant = self.referenceHeightView.frame.height
                self.view.layoutIfNeeded()
                self.directionsToVenueView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
            }
        }
    }
    
    fileprivate func shouldHideDirectionView(_ isHidden: Bool) {
        mainDirectionsLabel.isHidden = isHidden
        noticedLabel.isHidden = isHidden
        dismissButton.isHidden = isHidden
        mapsButton.isHidden = isHidden
    }

    fileprivate func loadCurrentUserLocationIfAvailable() {
        if CSLocationStatusHelper.locationServicesAvailable() {
            getCurrentUserLocation()
        }
    }
    
    fileprivate func getCurrentUserLocation() {
        guard let moduleViewController = moduleViewController else {
            present(CSAlertHelper.showAlertError(errorMessage: "Your current location is available."), animated: true)
            return
        }

        guard let startPoint = moduleViewController.currentLocation else {
            present(CSAlertHelper.showAlertError(errorMessage: "Your current location is not being reported."), animated: true)
            return
        }

        self.startPoint = startPoint
        userLocation = startPoint
        startPoinTextField.text = startPoint.title
        endPointTextField.becomeFirstResponder()
    }
    
    fileprivate func searchPOIs(searchTerm: String) {
        userIsSearching = searchTerm != ""
        
        let filteredPOIs = poiArray.filterBy(keyword: searchTerm)
        filteredPOIArray = filteredPOIs
        
        let tableViewContents = CSPointOfInterestsHelper.poiListSections(filteredPOIs)
        sectionsSearchResults = tableViewContents.sectionTitles
        pointOfInterestsSearchResults = tableViewContents.sections
        
        poiTableView.reloadData()
    }
    
    fileprivate func pointOfInterest(at indexPath: IndexPath) -> PWMapPoint {
        let sectionToList = userIsSearching ? pointOfInterestsSearchResults[indexPath.section] : sortedPointOfInterests[indexPath.section]
        return sectionToList.poinOfInterests[indexPath.row]
    }
    
    fileprivate func setSelectedPOI(_ poi: PWMapPoint) {
        if lastEditedTextField == startPoinTextField {
            startPoint = poi
            startPoinTextField.text = poi.title!
        } else {
            destinationPoint = poi
            endPointTextField.text = poi.title!
        }
    }
    
    fileprivate func clearSelections(textFieldTag: Int) {
        guard let textFieldDidCancel = view.viewWithTag(textFieldTag) else {
            return
        }
        if textFieldDidCancel == startPoinTextField {
            startPoint = nil
        } else {
            destinationPoint = nil
        }
    }
    
    @objc fileprivate func textFieldDidChange(_ textField: UITextField) {
        searchPOIs(searchTerm: textField.text!)
    }
}

//MARK: - Validation Methods
extension CSRouteViewController {
    fileprivate func validateTextFieldSelection() {
        guard let lastEditedTextField = self.lastEditedTextField else {
            return
        }
        let currentText = lastEditedTextField.text!
        let searchedPOI = poiArray.first(where: { (poi) -> Bool in
            guard let  poiName = poi.title else {
                return false
            }
            return poiName!.localizedCaseInsensitiveContains(currentText)
        })

        if let validPOI = searchedPOI {
            setSelectedPOI(validPOI)
        } else {
            lastEditedTextField.text = ""
        }
    }

    fileprivate func valideRoutePOIs() -> Bool {
        guard let startPOI = startPoint, let endPOI = destinationPoint else {
            return false
        }
        return startPOI.identifier != endPOI.identifier
    }
    
    fileprivate func validateRoutePOIs() {
        guard let routeStartPOI = startPoint, let routeDestinationPOI = destinationPoint else {
            present(CSAlertHelper.showAlertError(errorMessage: "Both start and end locations must be specified to find a route."), animated: true)
            return
        }

        if routeStartPOI.identifier == routeDestinationPOI.identifier {
            present(CSAlertHelper.showAlertError(errorMessage: "The start and end locations must be different."), animated: true)
        } else {

            let progress = MBProgressHUD.showAdded(to: view, animated: false)
            
            let routeOptions = PWRouteOptions(accessibilityEnabled: true,
                                              landmarksEnabled: true,
                                              excludedPointIdentifiers: nil)
            // Calculate a route and plot on the map with our specified route options
            PWRoute.createRoute(from: routeStartPOI,
                                to: routeDestinationPOI,
                                options: routeOptions,
                                completion: { [weak self] (route, error) in
                                    DispatchQueue.main.async {
                                        progress.hide(animated: true)
                                    }

                                    if let routeError = error {
                                        logger(routeError.localizedDescription)
                                        self?.moduleViewController?.mapView.zoomToMapPoint(routeDestinationPOI)
                                        if routeError.localizedDescription == "Invalid end point." || routeError.localizedDescription == "Invalid start point." {
                                            self?.dismiss(animated: true)
                                            self?.moduleViewController?.zoomToInvalidDestinationPOS(routeDestinationPOI)
                                        } else {
                                            self?.present(CSAlertHelper.showAlertError(errorMessage: "Invalid route.\nPlease try again."), animated: true)
                                        }
                                     return
                                    }
                                    guard let generatedRoute = route else {
                                        self?.present(CSAlertHelper.showAlertError(errorMessage: "Invalid route.\nPlease try again."), animated: true)
                                        return
                                    }
                                    if let startTitlte = routeStartPOI.title as? String, let endTitle = routeDestinationPOI.title as? String {
                                        CSMapModule.sentEvent("Route: From: \(startTitlte) To: \(endTitle)")
                                    }
                                    
                                    let fromCurrentLocation = self?.userLocation?.isEqual(self?.startPoint) ?? false
                                    
                                    self?.delegate?.routeToDisplay(generatedRoute, origin: routeStartPOI, destination: routeDestinationPOI, fromCurrentLocation: fromCurrentLocation)
                                    self?.dismiss(animated: true)
            })
        }
    }
}

//MARK: - Keyboard Handling Methods
extension CSRouteViewController {
    @objc func keyboardWasShown(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let newContentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            poiTableView.contentInset = newContentInset
            poiTableView.scrollIndicatorInsets = newContentInset
        }
    }
    @objc  
    func keyboardDidHide(_ notification: Notification) {
        poiTableView.contentInset = .zero
        poiTableView.scrollIndicatorInsets = .zero
    }
}

//MARK: - UITableViewDelegate
extension CSRouteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPOI = pointOfInterest(at: indexPath)
        setSelectedPOI(selectedPOI)
    }
}

//MARK: - UITableViewDataSource
extension CSRouteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return userIsSearching ? pointOfInterestsSearchResults.count : sortedPointOfInterests.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return userIsSearching ? sectionsSearchResults : tableViewSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionToList = userIsSearching ? pointOfInterestsSearchResults[section] : sortedPointOfInterests[section]
        return sectionToList.poinOfInterests.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionToList = userIsSearching ? pointOfInterestsSearchResults[section] : sortedPointOfInterests[section]
        return sectionToList.poinOfInterests.count > 0 ? sectionHeaderHeight : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionToList = userIsSearching ? pointOfInterestsSearchResults[section] : sortedPointOfInterests[section]

        guard sectionToList.poinOfInterests.count > 0 else {
            return nil
        }
        guard let sectionHeaderView = tableView.dequeueReusableCell(withIdentifier: sectionHeaderViewCellIdentifier) as? CSTableSectionHeaderViewCell else {
            return nil
        }

        sectionHeaderView.sectionHeaderLabel.text = sectionToList.sectionHeader

        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let poiListCell = tableView.dequeueReusableCell(withIdentifier: poiListCellReuseIdentifier, for: indexPath) as? CSPOIListTableViewCell else {
            return UITableViewCell()
        }

        let poiToList = pointOfInterest(at: indexPath)
        if let poi = poiToList as? PWPointOfInterest {
            poiListCell.iconImageView.kf.setImage(with: poi.imageURL)
            poiListCell.poiNameLabel.text = poi.title
            poiListCell.poiFloorNumberLabel.text = poi.subtitle ?? poi.floor?.name
        } else if let poi = poiToList as? PWCustomPointOfInterest {
            poiListCell.iconImageView.image = poi.image
            poiListCell.poiNameLabel.text = poi.title
            poiListCell.poiFloorNumberLabel.text = poi.floor?.name
        }

        poiListCell.distanceLabel.text = nil
        
        return poiListCell
    }
}

extension CSRouteViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
