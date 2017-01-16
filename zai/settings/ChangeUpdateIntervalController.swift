//
//  ChangeUpdateIntervalController.swift
//  zai
//
//  Created by 渡部郷太 on 1/16/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

protocol ChangeUpdateIntervalDelegate {
    func saved(interval: UpdateInterval)
}

class ChangeUpdateIntervalController : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UpdateInterval.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard let interval = UpdateInterval(rawValue: indexPath.row) else {
            return cell
        }
        cell.textLabel?.text = interval.string
        if interval == self.config.autoUpdateInterval {
            self.selectedInterval = interval
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) else {
            return
        }
        cell.accessoryType = UITableViewCellAccessoryType.checkmark
        self.selectedInterval = UpdateInterval(rawValue: indexPath.row)!
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) else {
            return
        }
        cell.accessoryType = UITableViewCellAccessoryType.none
    }
    
    @IBAction func pushSaveButton(_ sender: Any) {
        self.config.autoUpdateInterval = self.selectedInterval
        _ = self.config.save()
        self.delegate?.saved(interval: self.config.autoUpdateInterval)
        self.performSegue(withIdentifier: "unwindToSettings", sender: self)
    }
    

    var config: Config!
    var selectedInterval: UpdateInterval = UpdateInterval.oneSecond
    var delegate: ChangeUpdateIntervalDelegate?
}
