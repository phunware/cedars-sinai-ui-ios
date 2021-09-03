//
//  CSDirectoryListViewController.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/18/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import PWMapKit
import UIKit
import Kingfisher

class CSDirectoryListViewController: UIViewController {

    @IBOutlet weak var directoryTableView: UITableView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var searchTextField: CSSearchTextField! {
        didSet {
            searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    @IBOutlet var searchTextFieldDelegate: CSTextFieldHandler! {
        didSet {
            searchTextFieldDelegate.textFieldDidBeginAction = { [weak self] _ in
                if self?.searchTextField.text == "" {
                    self?.userIsSearching = false
                    self?.setUpBuildingPOIsList()
                } else {
                    self?.userIsSearching = true
                    if let searchTerm = self?.searchTextField.text {
                        self?.filterBuildingPOIs(searchTerm: searchTerm)
                    }
                }
                self?.directoryTableView.reloadData()
            }
            searchTextFieldDelegate.textFieldClearAction = { [weak self] _ in
                self?.userIsSearching = false
                
                self?.setUpBuildingPOIsList()
                self?.directoryTableView.reloadData()
            }
        }
    }
    
    private let segueIdentifier = "poiFilterSegue"
    fileprivate let poiListCellReuseIdentifier = "directoryCell"
    fileprivate let sectionHeaderViewCellIdentifier = "headerCell"
    fileprivate let estimatedCellHeight = CGFloat(80)
    fileprivate let sectionHeaderHeight = CGFloat(30)
    fileprivate let searchBarDelegate = CSMapModuleSearchBarHandler()
    
    fileprivate var userIsSearching = false
    fileprivate var allBuildingPOIs: [PWMapPoint] = []
    fileprivate var tableViewSections: [String] = []
    fileprivate var sortedPointOfInterests: [CSDirectorySectionModel] = []
    fileprivate var sectionsSearchResults: [String] = []
    fileprivate var pointOfInterestsSearchResults: [PWMapPoint] = []
    fileprivate var categoryFilter: PWPointOfInterestType?
    fileprivate var allBuildingPOITypes: [PWPointOfInterestType]? {
        return currentBuilding.allCurrentPointOfInterestType()
    }

    fileprivate var parkingPOI: PWCustomPointOfInterest?
    
    public weak var containerViewController: CSMapModuleViewController!
    public var currentBuilding = PWBuilding()

    lazy var notificationCenter: NotificationCenter = NotificationCenter.default


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // NOTE: These notifications are needed before the view is loaded
        notificationCenter.addObserver(self, selector: #selector(didAddParkingPOI(_:)), name: Notification.Name.UserDidAddParkingPOI, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didRemoveParkingPOI(_:)), name: Notification.Name.UserDidRemoveParkingPOI, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        setUpViews()
        setUpBuildingPOIsList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNotifications()

        if let indexPathForSelectedCell = directoryTableView.indexPathForSelectedRow {
            directoryTableView.deselectRow(at: indexPathForSelectedCell, animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let parameters = [Event.Parameter.screenName.rawValue : "Directory"]
        CSMapModule.sendEvent(Event.Name.screenView.rawValue, paramaters: parameters)
        CSMapModule.startEvent("Directory", parameters: nil)
        logger("Start timed event", data: parameters)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CSMapModule.endEvent("Directory", parameters: nil)
        logger("End timed event")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetSearch()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            if let poiFilterViewController = segue.destination as? CSDirectoryFilterViewController, let currentBuildingPOITypes = allBuildingPOITypes, let poiTypeImagesArray = currentBuilding.getPointOfInterestTypeImages() {
                poiFilterViewController.pointOfInterestTypes = currentBuildingPOITypes
                poiFilterViewController.poiTypeImageModelArray = poiTypeImagesArray
                poiFilterViewController.currentSelectedFilter = categoryFilter
                poiFilterViewController.delegate = self
            }
        }
    }
}

// MARK:- View Configuration
extension CSDirectoryListViewController {

    fileprivate func setUpNotifications() {
        notificationCenter.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)

    }

    fileprivate func setUpViews() {

        directoryTableView.register(UINib(nibName: String(describing: CSPOIListTableViewCell.self), bundle: CSBundleHelper.bundle), forCellReuseIdentifier: poiListCellReuseIdentifier)
        directoryTableView.register(UINib(nibName: String(describing: CSTableSectionHeaderViewCell.self), bundle: CSBundleHelper.bundle), forCellReuseIdentifier: sectionHeaderViewCellIdentifier)
        directoryTableView.delegate = self
        directoryTableView.dataSource = self
        directoryTableView.tableFooterView = UIView() //To prevent showing empty cells
        directoryTableView.rowHeight = UITableView.automaticDimension
        directoryTableView.estimatedRowHeight = estimatedCellHeight
        directoryTableView.keyboardDismissMode = .interactive
    }
    
    fileprivate func setUpBuildingPOIsList() {
        guard let allPOIs: [PWMapPoint] = currentBuilding.allPointOfinterest() else {
            return
        }
        var buildingPOIs = allPOIs
        if let parkingPOI = parkingPOI {
            buildingPOIs.append(parkingPOI)
        }
        if let poiTypeFilter = categoryFilter {

            buildingPOIs = buildingPOIs.filter { mapPoint in
                if let poi = mapPoint as? PWPointOfInterest {
                    return poi.pointOfInterestType.identifier == poiTypeFilter.identifier
                } else if let poi = mapPoint as? PWCustomPointOfInterest {
                    return poi.pointOfInterestType?.identifier == poiTypeFilter.identifier
                } else {
                    return false
                }
            }
        }
        allBuildingPOIs = buildingPOIs
        
        let tableViewContents = CSPointOfInterestsHelper.poiListSections(allBuildingPOIs)
        tableViewSections = tableViewContents.sectionTitles
        sortedPointOfInterests = tableViewContents.sections
    }
    
    @objc fileprivate func textFieldDidChange(_ textField: UITextField) {
        userIsSearching = searchTextField.text != ""
        if userIsSearching {
            filterBuildingPOIs(searchTerm: searchTextField.text!)
        } else {
            setUpBuildingPOIsList()
        }
        directoryTableView.reloadData()
    }

    @objc fileprivate func didAddParkingPOI(_ notification: Notification) {
        if let poi = notification.object as? PWCustomPointOfInterest {
            parkingPOI = poi
        }
    }

    @objc fileprivate func didRemoveParkingPOI(_ notification: Notification) {
        parkingPOI = nil
    }

    fileprivate func resetSearch() {
        searchTextField.text = nil
        setUpBuildingPOIsList()
        directoryTableView.reloadData()
    }
}

// MARK:- POI Filter Helper Methods
extension CSDirectoryListViewController {
    fileprivate func pointOfInterest(at indexPath: IndexPath) -> PWMapPoint {
        return userIsSearching ? pointOfInterestsSearchResults[indexPath.row] : sortedPointOfInterests[indexPath.section].poinOfInterests[indexPath.row]
    }
    
    fileprivate func filterBuildingPOIs(searchTerm: String?) {
        // Move these 2 out
        let filter = categoryFilter
        let location = containerViewController.currentUserLocationInMap?.location
        let results = allBuildingPOIs
            .filterBy(keyword: searchTerm)
            .filterBy(category: filter)
            .sortBy(location: location)

        pointOfInterestsSearchResults = results
    }
}

// MARK:- Filter Delegate
extension CSDirectoryListViewController: PointOfInterestTypeFilterDelegate {
    func selectedFilter(_ poiType: PWPointOfInterestType?) {
        categoryFilter = poiType
        if userIsSearching {
            filterBuildingPOIs(searchTerm: searchTextField.text)
        } else {
            setUpBuildingPOIsList()
        }
        directoryTableView.reloadData()
    }
}

// MARK:- Keyboard Handling Methods
extension CSDirectoryListViewController {
    @objc func keyboardWasShown(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let insetHeight = keyboardHeight - toolbarView.frame.height
            
            let newContentInset = UIEdgeInsets(top: 0, left: 0, bottom: insetHeight, right: 0)
            directoryTableView.contentInset = newContentInset
            directoryTableView.scrollIndicatorInsets = newContentInset
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        directoryTableView.contentInset = .zero
        directoryTableView.scrollIndicatorInsets = .zero
    }
}

// MARK:- UITableViewDelegate
extension CSDirectoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPOI = pointOfInterest(at: indexPath)
        containerViewController.showSelectedPOIDetail(selectedPOI)

        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Filter Selected"])
    }
}

// MARK:- UITableViewDataSource
extension CSDirectoryListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return userIsSearching ? 1 : sortedPointOfInterests.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return userIsSearching ? sectionsSearchResults : tableViewSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userIsSearching ? pointOfInterestsSearchResults.count : sortedPointOfInterests[section].poinOfInterests.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if userIsSearching {
            return 0
        } else {
            let sectionToList = sortedPointOfInterests[section]
            return sectionToList.poinOfInterests.count > 0 ? sectionHeaderHeight : 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard tableView.numberOfRows(inSection: section) > 0 else {
            return nil
        }

        guard let sectionHeaderView = tableView.dequeueReusableCell(withIdentifier: sectionHeaderViewCellIdentifier) as? CSTableSectionHeaderViewCell else {
            return nil
        }
        if userIsSearching {
            return nil
        }

        let sectionTitle = sortedPointOfInterests[section].sectionHeader
        sectionHeaderView.sectionHeaderLabel.text = sectionTitle
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let poiListCell = tableView.dequeueReusableCell(withIdentifier: poiListCellReuseIdentifier, for: indexPath) as? CSPOIListTableViewCell else {
            return UITableViewCell()
        }

        let poiToList = pointOfInterest(at: indexPath)

        let userLocation = containerViewController.currentUserLocationInMap?.location
        if let poi = poiToList as? PWPointOfInterest {
            poiListCell.iconImageView.kf.setImage(with: poi.imageURL)
            poiListCell.poiNameLabel.text = poi.title
            poiListCell.poiFloorNumberLabel.text = poi.metadataSubtitle ?? poi.floor?.name
            poiListCell.distanceLabel.text = userIsSearching ? userLocation?.distance(from: poiToList.location).feet : nil
            poiListCell.distanceLabel.isHidden = true
        } else if let poi = poiToList as? PWCustomPointOfInterest {
            poiListCell.iconImageView.image = poi.image
            poiListCell.poiNameLabel.text = poi.title
            poiListCell.distanceLabel.text = userIsSearching ? userLocation?.distance(from: poiToList.location).feet : nil
            poiListCell.distanceLabel.isHidden = true
            poiListCell.poiFloorNumberLabel.text = poi.floor?.name
        }

        return poiListCell
    }
}
