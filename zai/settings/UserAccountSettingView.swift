//
//  UserIdSettingView.swift
//  zai
//
//  Created by Kyota Watanabe on 1/12/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit


protocol UserAccountSettingDelegate {
    func loggedOut(userId: String)
    func changePassword()
    func changeExchange(setting: UserAccountSettingView)
}

class UserAccountSettingView : SettingView, ValueActionSettingDelegate, VariableSettingCellDelegate, ChangeExchangeDelegate {
    
    init(account: Account, section: Int, tableView: UITableView) {
        self.account = account
        super.init(section: section, tableView: tableView)
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "valueActionSettingCell", for: indexPath) as! ValueActionSettingCell
            cell.valueLabel.text = self.account.userId
            cell.actionButton.setTitle(LabelResource.logout, for: UIControlState.normal)
            cell.actionButton.setTitleColor(Color.keyColor, for: UIControlState.normal)
            cell.actionButton.isEnabled = true
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = LabelResource.password
            cell.valueLabel.text = "*****"
            cell.id = 0
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = LabelResource.exchange
            cell.valueLabel.text = self.account.activeExchange.name
            cell.id = 1
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            cell.nameLabel.text = LabelResource.currencyPair
            cell.valueLabel.text = self.account.activeExchange.displayCurrencyPair
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            return cell
        }
    }
    
    override func shouldHighlightRowAt(row: Int) -> Bool {
        switch row {
        case 0:
            return false
        case 1:
            return true
        case 2:
            return false
        case 3:
            return false
        default:
            return false
        }
    }
    
    // ValueActionSettingDelegate
    func action(cell: ValueActionSettingCell, actionName: String) {
        cell.actionButton.isEnabled = false
        let userId = self.account.userId
        self.delegate?.loggedOut(userId: userId)
    }
    
    // VariableSettingCellDelegate
    func touchesEnded(id: Int, name: String, value: String) {
        switch id {
        case 0: self.delegate?.changePassword()
        case 1: self.delegate?.changeExchange(setting: self)
        default: break
        }
    }
    
    // ChangeExchangeDelegate
    func saved(exchange: String) {
        guard let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: self.section))  as? VariableSettingCell else {
            return
        }
        cell.valueLabel.text = exchange
    }
    
    override var sectionName: String {
        return "アカウント情報"
    }
    
    override var rowCount: Int {
        return 4
    }
    
    let account: Account
    var delegate: UserAccountSettingDelegate?
}
