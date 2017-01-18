//
//  ZaifSettingView.swift
//  zai
//
//  Created by 渡部郷太 on 1/14/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol ZaifSettingViewDelegate {
    func changeApiKeys()
}


class ZaifSettingView : SettingView, VariableSettingCellDelegate {
    
    init(zaifExchange: ZaifExchange, section: Int, tableView: UITableView) {
        self.zaifExchange = zaifExchange
        super.init(section: section, tableView: tableView)
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = "APIキー"
            cell.valueLabel.text = ""
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
    
    // VariableSettingCellDelegate
    func touchesEnded(name: String, value: String) {
        self.delegate?.changeApiKeys()
    }
    
    override var settingName: String {
        return self.zaifExchange.name
    }
    
    override var settingCount: Int {
        return 1
    }
    
    let zaifExchange: ZaifExchange
    var delegate: ZaifSettingViewDelegate?
}
