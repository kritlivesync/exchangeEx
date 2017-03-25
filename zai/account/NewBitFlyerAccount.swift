//
//  NewBitFlyerAccount.swift
//  zai
//
//  Created by 渡部郷太 on 2/17/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class NewBitFlyerAccount : SectionView {
    
    override init(section: Int, tableView: UITableView) {
        super.init(section: section, tableView: tableView)
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textSettingCell", for: indexPath) as! TextSettingCell
            cell.textField.placeholder = LabelResource.apiKeyPlaceholder
            
            // for debug
            //cell.textField.text = testbFKey
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textSettingCell", for: indexPath) as! TextSettingCell
            cell.textField.placeholder = LabelResource.secretKeyPlaceholder
            
            // for debug
            //cell.textField.text = testbFSecret
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func shouldHighlightRowAt(row: Int) -> Bool {
        return false
    }
    
    override var sectionName: String {
        return LabelResource.biyFlyerApiKeySection
    }
    
    override var rowCount: Int {
        return 2
    }
    
    func validate(callback: @escaping (ZaiError?) -> Void) {
        let apiKey = self.getApiKey()
        let secretKey = self.getSecretKey()
        
        if apiKey == "" && secretKey == "" {
            callback(nil)
        }
        
        let api = bitFlyerApi(apiKey: apiKey, secretKey: secretKey)
        api.validateApi() { err in
            if err == nil {
                callback(nil)
                return
            }
            let resource = bitFlyerResource()
            
            switch err!.errorType {
            case ApiErrorType.NO_PERMISSION:
                callback(ZaiError(errorType: .INVALID_API_KEYS_NO_PERMISSION, message: resource.apiKeyNoPermission))
            case ApiErrorType.NONCE_NOT_INCREMENTED:
                callback(ZaiError(errorType: ZaiErrorType.NONCE_NOT_INCREMENTED, message: resource.apiKeyNonceNotIncremented))
            case ApiErrorType.INVALID_API_KEY:
                callback(ZaiError(errorType: ZaiErrorType.INVALID_API_KEYS, message: resource.invalidApiKey))
            case ApiErrorType.CONNECTION_ERROR:
                callback(ZaiError(errorType: ZaiErrorType.CONNECTION_ERROR, message: Resource.networkConnectionError))
            default:
                callback(ZaiError(errorType: .INVALID_API_KEYS, message: resource.invalidApiKey))
            }
        }
    }
    
    func getApiKey() -> String {
        guard let apiKeyCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.section)) as! TextSettingCell? else {
            return ""
        }
        return apiKeyCell.textField.text!
    }
    
    func getSecretKey() -> String {
        guard let secretKeyCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: self.section)) as! TextSettingCell? else {
            return ""
        }
        return secretKeyCell.textField.text!
    }
    
}
