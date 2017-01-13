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
}

class UserAccountSettingView : SettingProtocol, ValueActionSettingDelegate {
    
    init(account: Account) {
        self.account = account
    }
    
    func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
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
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            return cell
        }
    }
    
    // ValueActionSettingDelegate
    func action(actionName: String) {
        let userId = self.account.userId
        self.delegate?.loggedOut(userId: userId)
    }
    
    var settingName: String {
        return "アカウント情報"
    }
    
    var settingCount: Int {
        return 2
    }
    
    let account: Account
    var delegate: UserAccountSettingDelegate?
}
