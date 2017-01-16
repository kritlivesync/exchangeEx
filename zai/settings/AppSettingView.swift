//
//  AppSettingView.swift
//  zai
//
//  Created by 渡部郷太 on 1/16/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol AppSettingViewDelegate {
    func changeUpdateInterval()
}



class AppSettingView : SettingView, VariableSettingCellDelegate {
    
    init(config: Config, section: Int) {
        self.config = config
        super.init(section: section)
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = "自動更新間隔"
            cell.valueLabel.text = self.config.autoUpdateInterval.string
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
    
    func updateAutoUpdateInterval(tableView: UITableView, interval: UpdateInterval) {
        let index = IndexPath(row: 0, section: self.section)
        guard let cell = tableView.cellForRow(at: index) as? VariableSettingCell else {
            return
        }
        cell.valueLabel.text = interval.string
    }
    
    // VariableSettingCellDelegate
    func touchesEnded(name: String, value: String) {
        self.delegate?.changeUpdateInterval()
    }
    
    override var settingName: String {
        return ""
    }
    
    override var settingCount: Int {
        return 1
    }
    
    let config: Config
    var delegate: AppSettingViewDelegate?
}
