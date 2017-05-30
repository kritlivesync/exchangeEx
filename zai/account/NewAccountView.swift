//
//  NewAccountView.swift
//  zai
//
//  Created by 渡部郷太 on 2/12/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


struct UserIdValidator : TextSettingCellDelegate {
    func shouldChangeCharactersIn(existingString: String, addedString: String, range: NSRange) -> Bool {
        return validateUserId(existingInput: existingString, addedString: addedString)
    }
}

struct PasswordValidator : TextSettingCellDelegate {
    func shouldChangeCharactersIn(existingString: String, addedString: String, range: NSRange) -> Bool {
        return validatePassword(existingInput: existingString, addedString: addedString)
    }
}


class NewAccountView : SectionView {
    
    override init(section: Int, tableView: UITableView) {
        super.init(section: section, tableView: tableView)
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textSettingCell", for: indexPath) as! TextSettingCell
            cell.textField.placeholder = LabelResource.userIdPlacecholder + " " + LabelResource.required
            cell.textField.keyboardType = UIKeyboardType.asciiCapable
            cell.delegate = UserIdValidator()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textSettingCell", for: indexPath) as! TextSettingCell
            cell.textField.placeholder = LabelResource.passwordPlaceholder + " " + LabelResource.required
            cell.textField.keyboardType = UIKeyboardType.asciiCapable
            cell.textField.isSecureTextEntry = true
            cell.delegate = PasswordValidator()
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textSettingCell", for: indexPath) as! TextSettingCell
            cell.textField.placeholder = LabelResource.passwordAgainPlaceholder + " " + LabelResource.required
            cell.textField.keyboardType = UIKeyboardType.asciiCapable
            cell.textField.isSecureTextEntry = true
            cell.delegate = PasswordValidator()
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func shouldHighlightRowAt(row: Int) -> Bool {
        return false
    }
    
    override var sectionName: String {
        return ""
    }
    
    override var rowCount: Int {
        return 3
    }
    
    func validate() -> ZaiError? {
        let userId = self.getUserId()
        if validateUserId(userId: userId) == false {
            return ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.invalidUserIdLength)
        }
        
        let password = self.getPassword()
        if validatePassword(password: password) == false {
            return ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.invalidPasswordLength)
        }
        
        if let _ = AccountRepository.getInstance().findByUserId(userId) {
            return ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.userIdAlreadyUsed)
        }
        
        let passwordAgain = self.getPasswordAgain()
        if password != passwordAgain {
            return ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.passwordAgainNotMatch)
        }
        
        return nil
    }
    
    func getUserId() -> String {
        guard let userIdCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.section)) as! TextSettingCell? else {
            return ""
        }
        return userIdCell.textField.text!
    }
    
    func getPassword() -> String {
        guard let passwordCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: self.section)) as! TextSettingCell? else {
            return ""
        }
        return passwordCell.textField.text!
    }
    
    func getPasswordAgain() -> String {
        guard let pwAgainCell = self.tableView.cellForRow(at: IndexPath(row: 2, section: self.section)) as! TextSettingCell? else {
            return ""
        }
        return pwAgainCell.textField.text!
    }
    
}
