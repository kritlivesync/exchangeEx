//
//  ChangeUnwindingRuleViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 1/22/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit

protocol ChangeUnwindingRuleDelegate {
    func saved(rule: UnwindingRule)
}

class ChangeUnwindingRuleViewController : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        self.title = LabelResource.unwindingRule
        self.navigationItem.leftBarButtonItem?.title = LabelResource.cancel
        self.navigationItem.rightBarButtonItem?.title = LabelResource.save
        
        self.config = getAppConfig()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UnwindingRule.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard let rule = UnwindingRule(rawValue: indexPath.row) else {
            return cell
        }
        cell.textLabel?.text = rule.string
        if rule == self.config.unwindingRuleType {
            self.selectedRule = rule
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
        self.selectedRule = UnwindingRule(rawValue: indexPath.row)!
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) else {
            return
        }
        cell.accessoryType = UITableViewCellAccessoryType.none
    }
    
    @IBAction func pushSaveButton(_ sender: Any) {
        self.delegate?.saved(rule: self.selectedRule)
        self.performSegue(withIdentifier: "unwindToSettings", sender: self)
    }
    
    
    var config: AppConfig!
    var selectedRule: UnwindingRule = UnwindingRule.mostBenefit
    var delegate: ChangeUnwindingRuleDelegate?
}
