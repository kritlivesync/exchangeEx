//
//  BitFlyerSettingView.swift
//  zai
//
//  Created by 渡部郷太 on 2/25/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol BitFlyerSettingViewDelegate {
    func changeApiKeys(setting: BitFlyerSettingView)
}


class BitFlyerSettingView : SettingView, VariableSettingCellDelegate {
    
    init(exchange: BitFlyerExchange, section: Int, tableView: UITableView) {
        self.exchange = exchange
        super.init(section: section, tableView: tableView)
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = LabelResource.apiKey
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
    func touchesEnded(id: Int, name: String, value: String) {
        self.delegate?.changeApiKeys(setting: self)
    }
    
    override var sectionName: String {
        return self.exchange.name
    }
    
    override var rowCount: Int {
        return 1
    }
    
    let exchange: BitFlyerExchange
    var delegate: BitFlyerSettingViewDelegate?
}
