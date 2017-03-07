//
//  NewZaifAccountView.swift
//  zai
//
//  Created by 渡部郷太 on 2/12/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import UIKit


class NewZaifAccountView : SectionView {
    
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
            //cell.textField.text = testKey

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textSettingCell", for: indexPath) as! TextSettingCell
            cell.textField.placeholder = LabelResource.secretKeyPlaceholder
            
            // for dubug
            //cell.textField.text = testSecret

            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func shouldHighlightRowAt(row: Int) -> Bool {
        return false
    }
    
    override var sectionName: String {
        return LabelResource.zaifApiKeySection
    }
    
    override var rowCount: Int {
        return 2
    }
    
    func validate(callback: @escaping (ZaiError?, Int64) -> Void) {
        let apiKey = self.getApiKey()
        let secretKey = self.getSecretKey()
        let zaifApi = ZaifApi(apiKey: apiKey, secretKey: secretKey)
        zaifApi.validateApi() { err in
            let nonce = zaifApi.api.nonceValue
            if err == nil {
                callback(nil, nonce)
                return
            }
            let resource = ZaifResource()
            
            switch err!.errorType {
            case ApiErrorType.NO_PERMISSION:
                callback(ZaiError(errorType: .INVALID_API_KEYS_NO_PERMISSION, message: resource.apiKeyNoPermission), nonce)
            case ApiErrorType.NONCE_NOT_INCREMENTED:
                callback(ZaiError(errorType: ZaiErrorType.NONCE_NOT_INCREMENTED, message: resource.apiKeyNonceNotIncremented), nonce)
            case ApiErrorType.INVALID_API_KEY:
                callback(ZaiError(errorType: ZaiErrorType.INVALID_API_KEYS, message: resource.invalidApiKey), nonce)
            case ApiErrorType.CONNECTION_ERROR:
                callback(ZaiError(errorType: ZaiErrorType.CONNECTION_ERROR, message: Resource.networkConnectionError), nonce)
            default:
                callback(ZaiError(errorType: .INVALID_API_KEYS, message: resource.invalidApiKey), nonce)
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
