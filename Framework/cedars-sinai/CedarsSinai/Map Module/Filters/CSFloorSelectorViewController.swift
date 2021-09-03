//
//  CSFloorSelectorViewController.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/19/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit

protocol SelectBuildingFloorDelegate: class {
    func didSelectFloor(_ floor: PWFloor)
}

class CSFloorSelectorViewController: CSBaseModalViewController {
    
    @IBOutlet weak var floorTableView: UITableView!
    
    fileprivate let floorCellConstant = "floorCell"
    fileprivate let cellSize = CGFloat(50)
    
    public var floors: [PWFloor] = []
    public var currentFloor: PWFloor?
    public weak var delegate: SelectBuildingFloorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        floorTableView.delegate = self
        floorTableView.dataSource = self
        floorTableView.rowHeight = cellSize
        floorTableView.tableFooterView = UIView() //To prevent showing empty cells
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let parameters = [Event.Parameter.screenName.rawValue : "Floor Selector"]
        CSMapModule.sendEvent(Event.Name.screenView.rawValue, paramaters: parameters)
        CSMapModule.startEvent("Floor Selector", parameters: nil)
        logger("Start timed event", data: parameters)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CSMapModule.endEvent("Floor Selector", parameters: nil)
        logger("End timed event")
    }

    //MARK: - Actions
    @IBAction func didPressCloseButton(_ sender: Any) {
        closeFloorSelector()
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Close Floor Selector"])
    }

    //MARK: - Close
    fileprivate func closeFloorSelector() {
        dismiss(animated: true)
    }

}

//MARK: - UITableViewDelegate
extension CSFloorSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFloor = floors[indexPath.row]
        delegate?.didSelectFloor(selectedFloor)
        closeFloorSelector()

        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Floor Selected"])
    }
}

//MARK: - UITableViewDataSource
extension CSFloorSelectorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return floors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let floorCell = tableView.dequeueReusableCell(withIdentifier: floorCellConstant, for: indexPath) as? CSFloorTableViewCell else {
            return UITableViewCell()
        }

        let floorToDisplay = floors[indexPath.row]
        floorCell.floorNumberLabel.text = floorToDisplay.name
        
        if let displayedFloor = self.currentFloor, displayedFloor.floorID == floorToDisplay.floorID {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }

        return floorCell
    }
}
