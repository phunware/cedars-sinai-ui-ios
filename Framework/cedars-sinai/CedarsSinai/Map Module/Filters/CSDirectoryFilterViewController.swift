//
//  CSDirectoryFilterViewController.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/19/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit
import Kingfisher

protocol PointOfInterestTypeFilterDelegate: class {
    func selectedFilter(_ poiType: PWPointOfInterestType?)
}

class CSDirectoryFilterViewController: CSBaseModalViewController {
    
    @IBOutlet weak var poiTableView: UITableView!
    weak var delegate: PointOfInterestTypeFilterDelegate?
    
    fileprivate let poiCellIdentifier = "poiCell"
    fileprivate let cellSize = CGFloat(44)
    
    public var currentSelectedFilter: PWPointOfInterestType?
    public var pointOfInterestTypes: [PWPointOfInterestType]!
    public var poiTypeImageModelArray: [CSPOITypeImageModel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        setUpTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        CSMapModule.sendEvent(Event.Name.screenView.rawValue, paramaters: [Event.Parameter.screenName.rawValue : "POI Type Filter"])
    }
    
    @IBAction func clearButtonAction(_ sender: UIButton) {
        delegate?.selectedFilter(nil)
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Close Filter Selector"])
        dismiss(animated: true)
    }
}

// MARK:- View Configuration
extension CSDirectoryFilterViewController {
    fileprivate func setUpTableView() {
        poiTableView.delegate = self
        poiTableView.dataSource = self
        poiTableView.rowHeight = cellSize
        poiTableView.tableFooterView = UIView() //To prevent showing empty cells
    }
}

// MARK:- UITableViewDelegate
extension CSDirectoryFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedFilter(pointOfInterestTypes[indexPath.row])
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Filter Selected"])
        dismiss(animated: true)
    }
}

// MARK:- UITableViewDataSource
extension CSDirectoryFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pointOfInterestTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let poiCell = tableView.dequeueReusableCell(withIdentifier: poiCellIdentifier, for: indexPath) as? CSPOITableViewCell else {
            return UITableViewCell()
        }
        let poiToList = pointOfInterestTypes[indexPath.row]
        
        poiCell.poiNameLabel.text = CSMapModule.localizedString(poiToList.name)

        let poiTypeImageModel = poiTypeImageModelArray.filter { $0.poiTypeIdentifier == poiToList.identifier }.first
        poiCell.iconImageView?.kf.setImage(with: poiTypeImageModel?.imageUrl)

        if let currentFilter = currentSelectedFilter,
            currentFilter == poiToList {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return poiCell
    }
}
