//
//  AppSettingView.swift
//  zai
//
//  Created by 渡部郷太 on 1/16/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol AppSettingViewDelegate {
    func changeUnwindingPositionRule(setting: AppSettingView)
}


class AppSettingView : SettingView, VariableSettingCellDelegate, ChangeUnwindingRuleDelegate {
    
    override init(section: Int, tableView: UITableView) {
        self._config = getAppConfig()
        super.init(section: section, tableView: tableView)
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = "ポジション解消ルール"
            cell.valueLabel.text = self._config.unwindingRule.string
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            return cell
        }
    }
    
    override func shouldHighlightRowAt(row: Int) -> Bool {
        switch row {
        case 0:
            return true
        default:
            return false
        }
    }
    
    func updateUnwindingRule(tableView: UITableView, rule: UnwindingRule) {
        let index = IndexPath(row: 0, section: self.section)
        guard let cell = tableView.cellForRow(at: index) as? VariableSettingCell else {
            return
        }
        cell.valueLabel.text = rule.string
    }
    
    // VariableSettingCellDelegate
    func touchesEnded(name: String, value: String) {
        self.delegate?.changeUnwindingPositionRule(setting: self)
    }
    
    // ChangeUnwindingRuleDelegate
    func saved(rule: UnwindingRule) {
        self.updateUnwindingRule(tableView: self.tableView, rule: rule)
    }
    
    override var sectionName: String {
        return ""
    }
    
    override var rowCount: Int {
        return 1
    }
    
    override var config: Config {
        return self._config
    }
    
    let _config: AppConfig
    var delegate: AppSettingViewDelegate?
}
