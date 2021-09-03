//
//  CSRoutingDirectionsListViewController.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/4/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit

class CSRoutingDirectionsListViewController: CSBaseModalViewController {

    @IBOutlet weak var directionsTableView: UITableView!
    @IBOutlet weak var originPoiImageView: UIImageView!
    @IBOutlet weak var originPoiLabel: UILabel!
    @IBOutlet weak var destinationPoiImageView: UIImageView!
    @IBOutlet weak var destinationPoiLabel: UILabel!

    fileprivate let cellReuseIdentifier = "routeDirectionCell"
    fileprivate let estimatedCellHeight = CGFloat(81)
    
    var routeDirections: [PWRouteInstruction] = []

    var originPOI: PWMapPoint?
    var destinationPOI: PWMapPoint?
    var building: PWBuilding?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        directionsTableView.dataSource = self
        directionsTableView.register(UINib(nibName: String(describing: CSRouteDirectionTableViewCell.self), bundle: CSBundleHelper.bundle), forCellReuseIdentifier: cellReuseIdentifier)
        directionsTableView.rowHeight = UITableView.automaticDimension
        directionsTableView.estimatedRowHeight = estimatedCellHeight

        setUpViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let parameters = [Event.Parameter.screenName.rawValue : "Route Directions"]
        CSMapModule.sendEvent(Event.Name.screenView.rawValue, paramaters: parameters)
        CSMapModule.startEvent("Route Directions", parameters: nil)
        logger("Start timed event", data: parameters)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CSMapModule.endEvent("Route Directions", parameters: nil)
        logger("End timed event")
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true)
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.screenName.rawValue : "Dismiss Route Directions"])
    }

    // MARK: - Build View
    fileprivate func setUpViews() {
        if let originPOI = originPOI as? PWPointOfInterest {
            originPoiImageView.kf.setImage(with: originPOI.imageURL)
            originPoiLabel.text = originPOI.title
        } else if let originPOI = originPOI as? PWCustomPointOfInterest {
            originPoiImageView.image = originPOI.image
            originPoiLabel.text = originPOI.title
        } else {
            originPoiImageView.image = UIImage(named: "ic_bluedot", in: CSBundleHelper.bundle, compatibleWith: nil)
            originPoiLabel.text = "Current Location"
        }

        if let destinationPOI = destinationPOI as? PWPointOfInterest {
            destinationPoiImageView.kf.setImage(with: destinationPOI.imageURL)
            destinationPoiLabel.text = destinationPOI.title
        } else if let destinationPOI = destinationPOI as? PWCustomPointOfInterest {
            destinationPoiImageView.image = destinationPOI.image
            destinationPoiLabel.text = destinationPOI.title
        }
    }
}

//MARK: - UITableViewDataSource
extension CSRoutingDirectionsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeDirections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let routeCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? CSRouteDirectionTableViewCell else {
            return UITableViewCell()
        }

        let instructionIndex = indexPath.row
        let instruction = routeDirections[instructionIndex]
        routeCell.routeInstruction = instruction
        
        return routeCell
    }
}
