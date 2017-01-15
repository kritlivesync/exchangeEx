//
//  ZaifSettingView.swift
//  zai
//
//  Created by 渡部郷太 on 1/14/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class ZaifSettingView : SettingProtocol {
    
    init(zaifExchange: ZaifExchange) {
        self.zaifExchange = zaifExchange
    }
    
    func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = "APIキー"
            cell.valueLabel.text = ""
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            return cell
        }
    }
    
    func shouldHighlightRowAt(row: Int) -> Bool {
        switch row {
        case 0:
            return true
        default:
            return false
        }
    }
    
    var settingName: String {
        return self.zaifExchange.name
    }
    
    var settingCount: Int {
        return 1
    }
    
    let zaifExchange: ZaifExchange
}