//
//  UserIdSettingView.swift
//  zai
//
//  Created by 渡部郷太 on 1/12/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol UserAccountSettingDelegate {
    func loggedOut(userId: String)
    func changePassword()
}

class UserAccountSettingView : SettingView, ValueActionSettingDelegate, VariableSettingCellDelegate {
    
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
            cell.actionButton.setTitle("ログアウト", for: UIControlState.normal)
            cell.actionButton.setTitleColor(Color.keyColor, for: UIControlState.normal)
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = "パスワード"
            cell.valueLabel.text = "*****"
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            cell.nameLabel.text = "現在の取引所"
            cell.valueLabel.text = self.account.activeExchange.name
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            cell.nameLabel.text = "取引中の通貨ペア"
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
    func action(actionName: String) {
        let userId = self.account.userId
        self.delegate?.loggedOut(userId: userId)
    }
    
    // VariableSettingCellDelegate
    func touchesEnded(name: String, value: String) {
        self.delegate?.changePassword()
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
