//
//  AppSettingView.swift
//  zai
//
//  Created by Kyota Watanabe on 1/16/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit


protocol AppSettingViewDelegate {
    func changeBuyAmountLimit(setting: AppSettingView)
    func changeUnwindingPositionRule(setting: AppSettingView)
}


class AppSettingView : SettingView, VariableSettingCellDelegate, ChangeUnwindingRuleDelegate, ChangeBuyAmountLimitDelegate {
    
    override init(section: Int, tableView: UITableView) {
        self._config = getAppConfig()
        super.init(section: section, tableView: tableView)
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = "買注文の上限数量"
            cell.valueLabel.text = formatValue(self._config.buyAmountLimitBtcValue) + "BTC"
            cell.id = 0
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = "ポジション解消ルール"
            cell.valueLabel.text = self._config.unwindingRuleType.string
            cell.id = 1
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            return cell
        }
    }
    
    override func shouldHighlightRowAt(row: Int) -> Bool {
        switch row {
        case 0, 1:
            return true
        default:
            return false
        }
    }
    
    func updateBuyAmountLimit(tableView: UITableView, amout: Double) {
        let index = IndexPath(row: 0, section: self.section)
        guard let cell = tableView.cellForRow(at: index) as? VariableSettingCell else {
            return
        }
        cell.valueLabel.text = formatValue(self._config.buyAmountLimitBtcValue) + "BTC"
    }
    
    func updateUnwindingRule(tableView: UITableView, rule: UnwindingRule) {
        let index = IndexPath(row: 1, section: self.section)
        guard let cell = tableView.cellForRow(at: index) as? VariableSettingCell else {
            return
        }
        cell.valueLabel.text = rule.string
    }
    
    // VariableSettingCellDelegate
    func touchesEnded(id: Int, name: String, value: String) {
        switch id {
        case 0:
            self.delegate?.changeBuyAmountLimit(setting: self)
        case 1:
            self.delegate?.changeUnwindingPositionRule(setting: self)
        default: break
            
        }
    }
    
    // ChangeBuyAmountLimitDelegate
    func saved(amount: Double) {
        self._config.buyAmountLimitBtcValue = amount
        self.updateBuyAmountLimit(tableView: self.tableView, amout: amount)
    }
    
    // ChangeUnwindingRuleDelegate
    func saved(rule: UnwindingRule) {
        self._config.unwindingRuleType = rule
        self.updateUnwindingRule(tableView: self.tableView, rule: rule)
    }
    
    override var sectionName: String {
        return ""
    }
    
    override var rowCount: Int {
        return 2
    }
    
    
    let _config: AppConfig
    var delegate: AppSettingViewDelegate?
}
